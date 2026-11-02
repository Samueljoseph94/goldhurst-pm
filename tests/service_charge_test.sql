-- Hand-checked service-charge scenario. Run after migrations; rolls back at the end.
-- Building: units A 1,000 sq ft, B 500, C 500, giving floor-area shares 0.50 / 0.25 / 0.25.
-- Year 2026 (365 days). Management fee 10%.
-- Budget: Cleaning 10,000 + Insurance 6,000 = 16,000.
-- Actual: Cleaning 12,000 + Insurance 6,000 = 18,000, plus a 500 cleaning line marked excluded.
-- T1 on A all year.
-- T2 on B from 1 Jul (184/365 days), cap 2,000.
-- T3 on C all year; lease fixes 20% and excludes Insurance.
--
-- Expected (budget):  T1 = 16,000 x 0.5 = 8,000 + 800 fee = 8,800.00
--                     T2 = 16,000 x 0.25 x 184/365 = 2,016.44 + 201.64 = 2,218.08, capped to 2,000.00
--                     T3 = 10,000 x 0.20 = 2,000 + 200 = 2,200.00
-- Expected (actual):  T1 = 9,000 + 900 = 9,900.00
--                     T2 = 18,000 x 0.126027 = 2,268.49 + 226.85, capped to 2,000.00
--                     T3 = 12,000 x 0.20 = 2,400 + 240 = 2,640.00
-- On-account: T1 4 x 2,200 = 8,800, so balancing charge 1,100.00
\set ON_ERROR_STOP 1
begin;
insert into companies (id, name) values ('10000000-0000-0000-0000-000000000001', 'Test Co');
insert into properties (id, company_id, name) values ('10000000-0000-0000-0000-0000000000b1', '10000000-0000-0000-0000-000000000001', 'Test Building');
insert into units (id, property_id, name, area_sqft) values
  ('10000000-0000-0000-0000-0000000000a1', '10000000-0000-0000-0000-0000000000b1', 'A', 1000),
  ('10000000-0000-0000-0000-0000000000a2', '10000000-0000-0000-0000-0000000000b1', 'B', 500),
  ('10000000-0000-0000-0000-0000000000a3', '10000000-0000-0000-0000-0000000000b1', 'C', 500);
insert into tenancies (id, property_id, name) values
  ('10000000-0000-0000-0000-0000000000c1', '10000000-0000-0000-0000-0000000000b1', 'T1'),
  ('10000000-0000-0000-0000-0000000000c2', '10000000-0000-0000-0000-0000000000b1', 'T2'),
  ('10000000-0000-0000-0000-0000000000c3', '10000000-0000-0000-0000-0000000000b1', 'T3');
insert into tenancy_units values
  ('10000000-0000-0000-0000-0000000000c1', '10000000-0000-0000-0000-0000000000a1'),
  ('10000000-0000-0000-0000-0000000000c2', '10000000-0000-0000-0000-0000000000a2'),
  ('10000000-0000-0000-0000-0000000000c3', '10000000-0000-0000-0000-0000000000a3');
insert into terms (tenancy_id, start_date, rolling) values
  ('10000000-0000-0000-0000-0000000000c1', '2025-06-01', true),
  ('10000000-0000-0000-0000-0000000000c2', '2026-07-01', true),
  ('10000000-0000-0000-0000-0000000000c3', '2024-01-01', true);

insert into sc_schedules (id, property_id, name, method, management_fee_pct)
  values ('10000000-0000-0000-0000-0000000000d1', '10000000-0000-0000-0000-0000000000b1', 'Building', 'floor_area', 10);
insert into sc_schedule_units (schedule_id, unit_id) select '10000000-0000-0000-0000-0000000000d1', id from units
  where property_id = '10000000-0000-0000-0000-0000000000b1';
insert into sc_heads (id, schedule_id, name) values
  ('10000000-0000-0000-0000-0000000000e1', '10000000-0000-0000-0000-0000000000d1', 'Cleaning'),
  ('10000000-0000-0000-0000-0000000000e2', '10000000-0000-0000-0000-0000000000d1', 'Insurance');
insert into sc_years (id, schedule_id, year_start, year_end)
  values ('10000000-0000-0000-0000-0000000000f1', '10000000-0000-0000-0000-0000000000d1', '2026-01-01', '2026-12-31');
insert into sc_budget_lines values
  ('10000000-0000-0000-0000-0000000000f1', '10000000-0000-0000-0000-0000000000e1', 10000, null),
  ('10000000-0000-0000-0000-0000000000f1', '10000000-0000-0000-0000-0000000000e2', 6000, null);
insert into sc_actual_lines (year_id, head_id, date, amount, excluded) values
  ('10000000-0000-0000-0000-0000000000f1', '10000000-0000-0000-0000-0000000000e1', '2026-03-31', 12000, false),
  ('10000000-0000-0000-0000-0000000000f1', '10000000-0000-0000-0000-0000000000e1', '2026-05-31', 500, true),
  ('10000000-0000-0000-0000-0000000000f1', '10000000-0000-0000-0000-0000000000e2', '2026-01-15', 6000, false);
insert into tenancy_sc_terms (tenancy_id, schedule_id, fixed_pct, cap_amount, excluded_heads) values
  ('10000000-0000-0000-0000-0000000000c2', '10000000-0000-0000-0000-0000000000d1', null, 2000, '{}'),
  ('10000000-0000-0000-0000-0000000000c3', '10000000-0000-0000-0000-0000000000d1', 20, null, '{10000000-0000-0000-0000-0000000000e2}');
insert into sc_demands (year_id, tenancy_id, period_start, period_end, amount_net)
  select '10000000-0000-0000-0000-0000000000f1', '10000000-0000-0000-0000-0000000000c1', d, (d + interval '3 months - 1 day')::date, 2200
  from generate_series('2026-01-01'::date, '2026-10-01', interval '3 months') d;

create temp table expected (tenancy text, budget numeric, actual numeric, balance numeric);
insert into expected values ('T1', 8800.00, 9900.00, 1100.00), ('T2', 2000.00, 2000.00, 2000.00), ('T3', 2200.00, 2640.00, 2640.00);

create temp table got as
select t.name as tenancy, b.charge as budget, a.charge as actual, r.balance
from sc_tenancy_charges('10000000-0000-0000-0000-0000000000f1', false) b
join sc_tenancy_charges('10000000-0000-0000-0000-0000000000f1', true) a using (tenancy_id)
join sc_reconcile('10000000-0000-0000-0000-0000000000f1') r using (tenancy_id)
join tenancies t on t.id = b.tenancy_id;

select g.*, case when g.budget = e.budget and g.actual = e.actual and g.balance = e.balance then 'PASS' else 'FAIL' end as result
from got g join expected e using (tenancy) order by tenancy;

select 'T2 uncapped budget', gross_share + mgmt_fee as uncapped, capped
from sc_tenancy_charges('10000000-0000-0000-0000-0000000000f1', false) where tenancy_id = '10000000-0000-0000-0000-0000000000c2';
select 'landlord shortfall (actual)', round(sc_landlord_shortfall('10000000-0000-0000-0000-0000000000f1', true), 2);
rollback;
