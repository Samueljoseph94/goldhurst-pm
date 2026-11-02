-- Goldhurst PM — row-level security
-- Staff see the companies they're members of; owner_viewer members (e.g. Hyjan) see only
-- their own company and can't write. Runs on Supabase, where auth.uid() is the signed-in user.

-- Supabase provides auth.uid(); only define a stand-in when running on plain Postgres (tests).
create schema if not exists auth;
do $$ begin
  if not exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                 where n.nspname = 'auth' and p.proname = 'uid') then
    execute 'create function auth.uid() returns uuid language sql stable as '
         || quote_literal('select nullif(current_setting(''request.jwt.claim.sub'', true), '''')::uuid');
  end if;
end $$;

-- Views must apply the querying user's row-level security, not the owner's.
alter view tenancy_arrears     set (security_invoker = true);
alter view compliance_status_v set (security_invoker = true);
alter view key_dates           set (security_invoker = true);
alter view reserve_balances    set (security_invoker = true);
alter view sc_unit_shares      set (security_invoker = true);

create or replace function app_can_read(p_company uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from memberships m where m.user_id = auth.uid() and m.company_id = p_company)
$$;

create or replace function app_can_write(p_company uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from memberships m where m.user_id = auth.uid()
                 and m.company_id = p_company and m.role in ('admin', 'manager'))
$$;

create or replace function company_of_property(p uuid) returns uuid
language sql stable security definer set search_path = public as $$ select company_id from properties where id = p $$;

create or replace function company_of_tenancy(t uuid) returns uuid
language sql stable security definer set search_path = public as $$
  select p.company_id from tenancies x join properties p on p.id = x.property_id where x.id = t $$;

create or replace function company_of_sc_schedule(s uuid) returns uuid
language sql stable security definer set search_path = public as $$
  select p.company_id from sc_schedules x join properties p on p.id = x.property_id where x.id = s $$;

create or replace function company_of_sc_year(y uuid) returns uuid
language sql stable security definer set search_path = public as $$
  select company_of_sc_schedule(schedule_id) from sc_years where id = y $$;

do $$
declare r record;
begin
  for r in select * from (values
    ('companies',          'id'),
    ('contacts',           'company_id'),
    ('properties',         'company_id'),
    ('documents',          'company_id'),
    ('reminders',          'company_id'),
    ('notes',              'company_id'),
    ('xero_invoices',      'company_id'),
    ('xero_bill_lines',    'company_id'),
    ('units',              'company_of_property(property_id)'),
    ('tenancies',          'company_of_property(property_id)'),
    ('compliance_items',   'company_of_property(property_id)'),
    ('maintenance_jobs',   'company_of_property(property_id)'),
    ('sc_schedules',       'company_of_property(property_id)'),
    ('reserve_funds',      'company_of_property(property_id)'),
    ('s20_consultations',  'company_of_property(property_id)'),
    ('tenancy_units',      'company_of_tenancy(tenancy_id)'),
    ('tenancy_contacts',   'company_of_tenancy(tenancy_id)'),
    ('terms',              'company_of_tenancy(tenancy_id)'),
    ('charge_schedules',   'company_of_tenancy(tenancy_id)'),
    ('deposits',           'company_of_tenancy(tenancy_id)'),
    ('tenancy_sc_terms',   'company_of_tenancy(tenancy_id)'),
    ('sc_schedule_units',  'company_of_sc_schedule(schedule_id)'),
    ('sc_heads',           'company_of_sc_schedule(schedule_id)'),
    ('sc_years',           'company_of_sc_schedule(schedule_id)'),
    ('sc_budget_lines',    'company_of_sc_year(year_id)'),
    ('sc_actual_lines',    'company_of_sc_year(year_id)'),
    ('sc_demands',         'company_of_sc_year(year_id)'),
    ('sc_reconciliations', 'company_of_sc_year(year_id)')
  ) as t(tbl, expr)
  loop
    execute format('alter table %I enable row level security', r.tbl);
    execute format('create policy %I on %I for select using (app_can_read(%s))', r.tbl || '_read', r.tbl, r.expr);
    execute format('create policy %I on %I for all using (app_can_write(%s)) with check (app_can_write(%s))',
                   r.tbl || '_write', r.tbl, r.expr, r.expr);
  end loop;
end $$;

alter table memberships enable row level security;
create policy memberships_self on memberships for select using (user_id = auth.uid());

-- reserve_movements isn't company-scoped directly; restrict via its fund
alter table reserve_movements enable row level security;
create policy reserve_movements_read on reserve_movements for select
  using (app_can_read(company_of_property((select property_id from reserve_funds f where f.id = fund_id))));
create policy reserve_movements_write on reserve_movements for all
  using (app_can_write(company_of_property((select property_id from reserve_funds f where f.id = fund_id))))
  with check (app_can_write(company_of_property((select property_id from reserve_funds f where f.id = fund_id))));
