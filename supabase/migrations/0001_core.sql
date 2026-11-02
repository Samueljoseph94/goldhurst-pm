-- Goldhurst PM — core schema
-- Principle: Xero is the ledger of record. This database holds tenancies, schedules and
-- service-charge workings, and caches Xero invoices/payments read-only. It never records
-- its own payments or allocations.

create extension if not exists pgcrypto;

-- ───────────────────────── Enums ─────────────────────────
create type member_role      as enum ('admin', 'manager', 'owner_viewer');
create type contact_category as enum ('person', 'company', 'owner', 'supplier', 'agent');
create type tenancy_status   as enum ('future', 'current', 'holding_over', 'vacating', 'expired');
create type tenancy_kind     as enum ('commercial_lease', 'licence', 'ast', 'long_lease', 'other');
create type contact_role     as enum ('primary_tenant', 'invoice_contact', 'guarantor', 'additional');
create type charge_kind      as enum ('rent', 'licence_fee', 'service_charge', 'insurance', 'rates', 'utilities', 'other');
create type frequency        as enum ('weekly', 'monthly', 'quarterly', 'usual_quarter_days', 'half_yearly', 'annually');
create type billing_basis    as enum ('in_advance', 'in_arrears');
create type doc_kind         as enum ('licence', 'lease', 'notice', 'certificate', 'invoice', 'correspondence', 'photo', 'other');
create type compliance_status as enum ('valid', 'due_soon', 'expired', 'not_required');

-- ───────────────────────── Tenancy model ─────────────────────────
-- A company = one client entity = one Xero organisation.
create table companies (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  xero_tenant_id text unique,
  vat_registered boolean not null default true,
  default_vat_rate numeric(5,2) not null default 20.00,
  created_at    timestamptz not null default now()
);

create table memberships (
  user_id    uuid not null,              -- auth.users.id in Supabase
  company_id uuid not null references companies(id) on delete cascade,
  role       member_role not null,
  primary key (user_id, company_id)
);

create table contacts (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references companies(id) on delete cascade,
  category      contact_category not null default 'person',
  name          text not null,
  correspondence_name text,
  email         text,
  phone         text,
  address       text,
  xero_contact_id text,
  released_id   bigint,                  -- source id from Re-Leased import
  archived      boolean not null default false,
  created_at    timestamptz not null default now()
);
create index on contacts (company_id);

create table properties (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references companies(id) on delete cascade,
  name          text not null,
  address       text,
  postcode      text,
  owner_contact_id uuid references contacts(id),
  is_residential boolean not null default false,
  released_id   bigint,
  created_at    timestamptz not null default now()
);
create index on properties (company_id);

create table units (
  id            uuid primary key default gen_random_uuid(),
  property_id   uuid not null references properties(id) on delete cascade,
  name          text not null,           -- 'Studio 16a', 'Ground Floor', 'Flat 7'
  floor         int,
  unit_type     text,                    -- studio, warehouse, flat, office
  area_sqft     numeric(10,2),
  epc_rating    text,
  vat_elected   boolean not null default false,
  lettable      boolean not null default true,
  released_id   bigint,
  unique (property_id, name)
);

create table tenancies (
  id            uuid primary key default gen_random_uuid(),
  property_id   uuid not null references properties(id) on delete cascade,
  name          text not null,           -- tenant / trading name
  kind          tenancy_kind not null default 'licence',
  form          text,                    -- e.g. 'Licence Inc Rates'
  status        tenancy_status not null default 'current',
  inside_1954_act boolean not null default false,
  is_residential boolean not null default false,
  reference     text,
  notice_months int,                     -- e.g. 2 months' notice on Creekside licences
  released_id   bigint unique,
  created_at    timestamptz not null default now()
);
create index on tenancies (property_id, status);

create table tenancy_units (
  tenancy_id uuid not null references tenancies(id) on delete cascade,
  unit_id    uuid not null references units(id),
  primary key (tenancy_id, unit_id)
);

create table tenancy_contacts (
  tenancy_id uuid not null references tenancies(id) on delete cascade,
  contact_id uuid not null references contacts(id),
  role       contact_role not null,
  primary key (tenancy_id, contact_id, role)
);

create table terms (
  id            uuid primary key default gen_random_uuid(),
  tenancy_id    uuid not null references tenancies(id) on delete cascade,
  start_date    date not null,
  end_date      date,                    -- null = rolling / periodic
  rolling       boolean not null default false,
  break_dates   date[] not null default '{}',
  is_current    boolean not null default true
);
create unique index one_current_term on terms (tenancy_id) where is_current;

-- Recurring charges that generate Xero invoices.
create table charge_schedules (
  id            uuid primary key default gen_random_uuid(),
  tenancy_id    uuid not null references tenancies(id) on delete cascade,
  kind          charge_kind not null,
  amount_net    numeric(12,2) not null,  -- per period, ex VAT
  vat_rate      numeric(5,2) not null default 20.00,
  frequency     frequency not null default 'monthly',
  due_day       int not null default 1,
  basis         billing_basis not null default 'in_advance',
  start_date    date not null,
  end_date      date,
  xero_account_code text,
  xero_tracking text,
  invoice_days_ahead int not null default 7,
  sc_schedule_id uuid,                    -- set when kind = service_charge (FK added below)
  active        boolean not null default true
);
create index on charge_schedules (tenancy_id) where active;

create table deposits (
  id            uuid primary key default gen_random_uuid(),
  tenancy_id    uuid not null references tenancies(id) on delete cascade,
  amount        numeric(12,2) not null,
  held_by       text,                     -- account / scheme
  scheme_ref    text,                     -- residential deposit protection ref
  received_on   date,
  returned_on   date
);

-- ───────────────────────── Xero cache (read-only mirror) ─────────────────────────
create table xero_invoices (
  xero_invoice_id text primary key,
  company_id    uuid not null references companies(id) on delete cascade,
  tenancy_id    uuid references tenancies(id),
  charge_schedule_id uuid references charge_schedules(id),
  number        text,
  kind          text not null,            -- ACCREC / ACCPAY / ACCRECCREDIT ...
  issue_date    date,
  due_date      date,
  period_start  date,
  period_end    date,
  total         numeric(12,2),
  amount_due    numeric(12,2),
  amount_paid   numeric(12,2),
  status        text,                     -- DRAFT / AUTHORISED / PAID / VOIDED
  synced_at     timestamptz not null default now()
);
create index on xero_invoices (tenancy_id, due_date);

create table xero_bill_lines (               -- expense lines feeding service-charge actuals
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references companies(id) on delete cascade,
  xero_invoice_id text not null,
  supplier      text,
  date          date not null,
  description   text,
  account_code  text,
  tracking      text,
  amount_net    numeric(12,2) not null,
  vat           numeric(12,2) not null default 0,
  synced_at     timestamptz not null default now()
);

-- Arrears derived purely from Xero data.
create view tenancy_arrears as
select t.id as tenancy_id, t.name, p.name as property,
       coalesce(sum(i.amount_due) filter (where i.due_date < current_date and i.status = 'AUTHORISED'), 0) as overdue,
       min(i.due_date) filter (where i.amount_due > 0 and i.status = 'AUTHORISED') as oldest_unpaid_due,
       max(i.period_end) filter (where i.status = 'PAID') as paid_to
from tenancies t
join properties p on p.id = t.property_id
left join xero_invoices i on i.tenancy_id = t.id and i.kind = 'ACCREC'
group by t.id, t.name, p.name;

-- ───────────────────────── Documents, dates, compliance ─────────────────────────
create table documents (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references companies(id) on delete cascade,
  property_id   uuid references properties(id),
  tenancy_id    uuid references tenancies(id),
  contact_id    uuid references contacts(id),
  kind          doc_kind not null default 'other',
  title         text not null,
  storage_path  text not null,            -- Supabase Storage key
  signed        boolean not null default false,
  signed_on     date,
  esign_envelope_id text,
  extracted     jsonb,                     -- AI-extracted fields (fee, start date, studio...)
  uploaded_at   timestamptz not null default now()
);

create table compliance_items (
  id            uuid primary key default gen_random_uuid(),
  property_id   uuid not null references properties(id) on delete cascade,
  unit_id       uuid references units(id),
  kind          text not null,             -- EICR, gas safety, FRA, EPC, insurance, legionella ...
  issued_on     date,
  expires_on    date,
  responsible   text,                      -- landlord / tenant / owner
  document_id   uuid references documents(id),
  notes         text
);

create view compliance_status_v as
select c.*, case
  when expires_on is null then 'not_required'::compliance_status
  when expires_on < current_date then 'expired'
  when expires_on < current_date + 60 then 'due_soon'
  else 'valid' end as status
from compliance_items c;

create table reminders (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references companies(id) on delete cascade,
  property_id   uuid references properties(id),
  tenancy_id    uuid references tenancies(id),
  due_on        date not null,
  title         text not null,
  done          boolean not null default false,
  created_by    uuid
);

create table notes (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references companies(id) on delete cascade,
  property_id   uuid references properties(id),
  tenancy_id    uuid references tenancies(id),
  contact_id    uuid references contacts(id),
  body          text not null,
  created_by    uuid,
  created_at    timestamptz not null default now()
);

create table maintenance_jobs (
  id            uuid primary key default gen_random_uuid(),
  property_id   uuid not null references properties(id) on delete cascade,
  unit_id       uuid references units(id),
  title         text not null,
  supplier_id   uuid references contacts(id),
  status        text not null default 'open',   -- open / quoted / instructed / done / cancelled
  reported_on   date not null default current_date,
  due_on        date,
  cost_net      numeric(12,2),
  sc_recoverable boolean not null default false,
  xero_invoice_id text
);

-- Key dates: one calendar from every source.
create view key_dates as
select t.property_id, t.id as tenancy_id, tm.end_date as date, 'Term end: ' || t.name as label, 'term_end' as kind
  from terms tm join tenancies t on t.id = tm.tenancy_id where tm.is_current and tm.end_date is not null
union all
select t.property_id, t.id, unnest(tm.break_dates), 'Break: ' || t.name, 'break'
  from terms tm join tenancies t on t.id = tm.tenancy_id where tm.is_current
union all
select c.property_id, null, c.expires_on, 'Compliance: ' || c.kind, 'compliance'
  from compliance_items c where c.expires_on is not null
union all
select r.property_id, r.tenancy_id, r.due_on, r.title, 'reminder'
  from reminders r where not r.done;
