-- Goldhurst PM — service charge
-- Covers: schedules, apportionment, heads of expenditure, budgets, on-account demands,
-- actuals from Xero bills, year-end reconciliation (balancing charges/credits), caps and
-- collars, reserve funds, and s.20 consultation tracking for residential blocks.

create type sc_method   as enum ('floor_area', 'fixed_percentage', 'weighted', 'equal');
create type sc_year_status as enum ('draft', 'approved', 'demanding', 'closed', 'reconciled');
create type reserve_move as enum ('contribution', 'expenditure', 'interest', 'transfer');
create type s20_stage   as enum ('notice_of_intention', 'estimates', 'reasons_for_award', 'works', 'complete');

-- A schedule is a pool of cost shared between a set of units: 'Building', 'Estate', 'Lift'.
create table sc_schedules (
  id            uuid primary key default gen_random_uuid(),
  property_id   uuid not null references properties(id) on delete cascade,
  name          text not null,
  method        sc_method not null default 'floor_area',
  year_start_month int not null default 1 check (year_start_month between 1 and 12),
  demand_frequency frequency not null default 'quarterly',
  management_fee_pct numeric(5,2),          -- added to recoverable cost, if the leases allow
  landlord_bears_voids boolean not null default true,
  unique (property_id, name)
);

alter table charge_schedules
  add constraint charge_schedules_sc_fk foreign key (sc_schedule_id) references sc_schedules(id);

create table sc_schedule_units (
  schedule_id   uuid not null references sc_schedules(id) on delete cascade,
  unit_id       uuid not null references units(id),
  share_pct     numeric(8,5),              -- used when method = fixed_percentage
  weight        numeric(10,4),             -- used when method = weighted
  area_override numeric(10,2),             -- used when method = floor_area, else units.area_sqft
  primary key (schedule_id, unit_id)
);

create table sc_heads (
  id            uuid primary key default gen_random_uuid(),
  schedule_id   uuid not null references sc_schedules(id) on delete cascade,
  name          text not null,             -- Cleaning, Insurance, Repairs, Utilities, Reserve contribution
  xero_account_code text,                  -- bill lines on this code map to this head
  recoverable   boolean not null default true,
  is_reserve_contribution boolean not null default false,
  sort_order    int not null default 0,
  unique (schedule_id, name)
);

create table sc_years (
  id            uuid primary key default gen_random_uuid(),
  schedule_id   uuid not null references sc_schedules(id) on delete cascade,
  year_start    date not null,
  year_end      date not null,
  status        sc_year_status not null default 'draft',
  approved_on   date,
  certified_on  date,
  certified_by  text,                      -- accountant / surveyor certifying the accounts
  check (year_end > year_start),
  unique (schedule_id, year_start)
);

create table sc_budget_lines (
  year_id       uuid not null references sc_years(id) on delete cascade,
  head_id       uuid not null references sc_heads(id),
  amount        numeric(12,2) not null,
  note          text,
  primary key (year_id, head_id)
);

create table sc_actual_lines (
  id            uuid primary key default gen_random_uuid(),
  year_id       uuid not null references sc_years(id) on delete cascade,
  head_id       uuid not null references sc_heads(id),
  bill_line_id  uuid references xero_bill_lines(id),   -- null for manual accruals
  date          date not null,
  description   text,
  amount        numeric(12,2) not null,
  excluded      boolean not null default false,       -- challenged / non-recoverable
  exclusion_reason text
);
create unique index sc_actual_bill_once on sc_actual_lines (bill_line_id) where bill_line_id is not null;

-- Lease-specific terms that change a tenant's share.
create table tenancy_sc_terms (
  tenancy_id    uuid not null references tenancies(id) on delete cascade,
  schedule_id   uuid not null references sc_schedules(id) on delete cascade,
  fixed_pct     numeric(8,5),               -- lease fixes the share regardless of method
  cap_amount    numeric(12,2),              -- annual ceiling for this tenant
  collar_amount numeric(12,2),              -- annual floor
  excluded_heads uuid[] not null default '{}',  -- heads this lease doesn't allow
  primary key (tenancy_id, schedule_id)
);

create table sc_demands (
  id            uuid primary key default gen_random_uuid(),
  year_id       uuid not null references sc_years(id) on delete cascade,
  tenancy_id    uuid not null references tenancies(id),
  period_start  date not null,
  period_end    date not null,
  amount_net    numeric(12,2) not null,
  xero_invoice_id text,
  summary_of_rights_attached boolean not null default false,   -- s.21B LTA 1985, residential
  issued_on     date,
  unique (year_id, tenancy_id, period_start)
);

create table sc_reconciliations (
  id            uuid primary key default gen_random_uuid(),
  year_id       uuid not null references sc_years(id) on delete cascade,
  tenancy_id    uuid not null references tenancies(id),
  actual_share  numeric(12,2) not null,
  on_account    numeric(12,2) not null,
  balance       numeric(12,2) not null,     -- + balancing charge, − credit
  xero_invoice_id text,                     -- balancing invoice or credit note
  issued_on     date,
  unique (year_id, tenancy_id)
);

create table reserve_funds (
  id            uuid primary key default gen_random_uuid(),
  property_id   uuid not null references properties(id) on delete cascade,
  name          text not null,
  bank_account  text,                       -- designated trust/client account reference
  unique (property_id, name)
);

create table reserve_movements (
  id            uuid primary key default gen_random_uuid(),
  fund_id       uuid not null references reserve_funds(id) on delete cascade,
  year_id       uuid references sc_years(id),
  date          date not null,
  kind          reserve_move not null,
  amount        numeric(12,2) not null,     -- contributions/interest +, expenditure −
  description   text
);

create view reserve_balances as
select f.id as fund_id, f.property_id, f.name, coalesce(sum(m.amount), 0) as balance
from reserve_funds f left join reserve_movements m on m.fund_id = f.id
group by f.id;

create table s20_consultations (
  id            uuid primary key default gen_random_uuid(),
  property_id   uuid not null references properties(id) on delete cascade,
  title         text not null,
  is_qualifying_long_term_agreement boolean not null default false,
  stage         s20_stage not null default 'notice_of_intention',
  intention_sent_on date,
  observations_close_on date,              -- 30 days after notice
  estimates_sent_on date,
  estimates_close_on date,
  award_reasons_sent_on date,
  estimated_cost numeric(12,2),
  notes         text
);

-- ───────────────────────── Apportionment ─────────────────────────
-- Raw share of each unit in a schedule, by the schedule's method (sums to 1 across units).
create view sc_unit_shares as
with base as (
  select su.schedule_id, su.unit_id, s.method,
         coalesce(su.area_override, u.area_sqft, 0) as area,
         coalesce(su.weight, 0) as weight,
         coalesce(su.share_pct, 0) / 100.0 as pct
  from sc_schedule_units su
  join sc_schedules s on s.id = su.schedule_id
  join units u on u.id = su.unit_id
)
select schedule_id, unit_id,
  case method
    when 'floor_area'       then area   / nullif(sum(area)   over (partition by schedule_id), 0)
    when 'weighted'         then weight / nullif(sum(weight) over (partition by schedule_id), 0)
    when 'fixed_percentage' then pct
    when 'equal'            then 1.0 / count(*) over (partition by schedule_id)
  end::numeric(12,8) as share
from base;

-- Each tenancy's share for a year, pro-rated by days occupied within the year.
-- Unlet time stays with the landlord (landlord_bears_voids).
create or replace function sc_tenancy_shares(p_year uuid)
returns table (tenancy_id uuid, unit_share numeric, occupied_fraction numeric, effective_share numeric)
language sql stable as $$
  with y as (
    select sy.*, (sy.year_end - sy.year_start + 1)::numeric as days
    from sc_years sy where sy.id = p_year
  ),
  occ as (
    select tu.tenancy_id, us.share as unit_share,
      greatest(0, least(coalesce(tm.end_date, y.year_end), y.year_end)
                - greatest(tm.start_date, y.year_start) + 1)::numeric / y.days as frac
    from y
    join sc_unit_shares us on us.schedule_id = y.schedule_id
    join tenancy_units tu on tu.unit_id = us.unit_id
    join terms tm on tm.tenancy_id = tu.tenancy_id and tm.is_current
  ),
  agg as (
    select o.tenancy_id, sum(o.unit_share) as unit_share,
           max(o.frac) as frac
    from occ o group by o.tenancy_id
  )
  select a.tenancy_id,
         round(coalesce(st.fixed_pct / 100.0, a.unit_share), 8),
         round(a.frac, 6),
         round(coalesce(st.fixed_pct / 100.0, a.unit_share) * a.frac, 8)
  from agg a
  join y on true
  left join tenancy_sc_terms st on st.tenancy_id = a.tenancy_id and st.schedule_id = y.schedule_id
  where a.frac > 0;
$$;

-- Recoverable cost per head for a year: budget or actual, plus management fee where set.
create or replace function sc_year_cost(p_year uuid, p_actual boolean)
returns table (head_id uuid, amount numeric)
language sql stable as $$
  select h.id,
    case when p_actual then
      coalesce((select sum(a.amount) from sc_actual_lines a
                where a.year_id = p_year and a.head_id = h.id and not a.excluded), 0)
    else
      coalesce((select b.amount from sc_budget_lines b
                where b.year_id = p_year and b.head_id = h.id), 0)
    end
  from sc_years y
  join sc_heads h on h.schedule_id = y.schedule_id and h.recoverable
  where y.id = p_year;
$$;

-- Per-tenancy charge for a year, applying lease exclusions, management fee, cap and collar.
create or replace function sc_tenancy_charges(p_year uuid, p_actual boolean)
returns table (tenancy_id uuid, gross_share numeric, mgmt_fee numeric, charge numeric, capped boolean)
language sql stable as $$
  with s as (select * from sc_tenancy_shares(p_year)),
  y as (select sy.schedule_id, sc.management_fee_pct from sc_years sy
        join sc_schedules sc on sc.id = sy.schedule_id where sy.id = p_year),
  c as (select * from sc_year_cost(p_year, p_actual)),
  per as (
    select s.tenancy_id,
           sum(c.amount * s.effective_share)
             filter (where not (c.head_id = any(coalesce(st.excluded_heads, '{}')))) as gross
    from s cross join c
    left join tenancy_sc_terms st on st.tenancy_id = s.tenancy_id
                                and st.schedule_id = (select schedule_id from y)
    group by s.tenancy_id
  ),
  fee as (
    select p.tenancy_id, coalesce(p.gross, 0) as gross,
           round(coalesce(p.gross, 0) * coalesce((select management_fee_pct from y), 0) / 100.0, 2) as fee
    from per p
  )
  select f.tenancy_id, round(f.gross, 2), f.fee,
         round(least(greatest(f.gross + f.fee, coalesce(st.collar_amount, 0)),
                     coalesce(st.cap_amount, f.gross + f.fee)), 2),
         (st.cap_amount is not null and f.gross + f.fee > st.cap_amount)
  from fee f
  left join tenancy_sc_terms st on st.tenancy_id = f.tenancy_id
                              and st.schedule_id = (select schedule_id from y);
$$;

-- Year-end reconciliation: actual charge vs on-account demanded.
create or replace function sc_reconcile(p_year uuid)
returns table (tenancy_id uuid, actual_share numeric, on_account numeric, balance numeric)
language sql stable as $$
  select a.tenancy_id, a.charge,
         coalesce(d.billed, 0),
         a.charge - coalesce(d.billed, 0)
  from sc_tenancy_charges(p_year, true) a
  left join (select tenancy_id, sum(amount_net) as billed
             from sc_demands where year_id = p_year group by tenancy_id) d
    on d.tenancy_id = a.tenancy_id;
$$;

-- Landlord's void/cap shortfall: recoverable cost not passed to any tenant.
create or replace function sc_landlord_shortfall(p_year uuid, p_actual boolean)
returns numeric language sql stable as $$
  select coalesce((select sum(amount) from sc_year_cost(p_year, p_actual)), 0)
           * (1 + coalesce((select sc.management_fee_pct from sc_years sy
                            join sc_schedules sc on sc.id = sy.schedule_id where sy.id = p_year), 0) / 100.0)
       - coalesce((select sum(charge) from sc_tenancy_charges(p_year, p_actual)), 0);
$$;
