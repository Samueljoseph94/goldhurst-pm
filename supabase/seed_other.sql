-- Hyjan and Goldhurst PM Limited, imported from Re-Leased on 2 Nov 2026
insert into companies (id, name) values ('00000000-0000-0000-0000-000000000c02', 'Hyjan') on conflict (id) do nothing;
insert into companies (id, name) values ('00000000-0000-0000-0000-000000000c03', 'Goldhurst PM Limited') on conflict (id) do nothing;
insert into contacts (id, company_id, category, name) values ('00000000-0000-0000-0002-000000038236', '00000000-0000-0000-0000-000000000c02', 'owner', 'You Spot Property Holdings Ltd');
insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) values ('00000000-0000-0000-0001-000000038236', '00000000-0000-0000-0000-000000000c02', 'Flat 3/13 Chalcot Gardens', 'Flat 3 / 13 Chalcot Gardens, London Greater London NW3 4YB, United Kingdom', 'NW3 4YB', '00000000-0000-0000-0002-000000038236', true, 38236);
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000382360', '00000000-0000-0000-0001-000000038236', 'Whole property', 'flat');
insert into contacts (id, company_id, category, name) values ('00000000-0000-0000-0002-000000034544', '00000000-0000-0000-0000-000000000c03', 'owner', 'Natan Lempert Mizrahi');
insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) values ('00000000-0000-0000-0001-000000034544', '00000000-0000-0000-0000-000000000c03', '9 Princess Road', '9 Princess Road, London Greater London NW1 8JN, United Kingdom', 'NW1 8JN', '00000000-0000-0000-0002-000000034544', false, 34544);
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000345440', '00000000-0000-0000-0001-000000034544', 'Upper Flat', 'unit');
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000345441', '00000000-0000-0000-0001-000000034544', 'NUYU London', 'unit');
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000345442', '00000000-0000-0000-0001-000000034544', 'Basement Flat', 'unit');
insert into contacts (id, company_id, category, name) values ('00000000-0000-0000-0002-000000038119', '00000000-0000-0000-0000-000000000c02', 'owner', 'YSP Housing Limited');
insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) values ('00000000-0000-0000-0001-000000038119', '00000000-0000-0000-0000-000000000c02', '8 Victoria Mews', '8 Victoria Mews, London Greater London NW6 6SY, United Kingdom', 'NW6 6SY', '00000000-0000-0000-0002-000000038119', true, 38119);
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000381190', '00000000-0000-0000-0001-000000038119', 'Whole property', 'flat');
insert into contacts (id, company_id, category, name) values ('00000000-0000-0000-0002-000000038118', '00000000-0000-0000-0000-000000000c02', 'owner', 'Green Light Asset Management Limited');
insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) values ('00000000-0000-0000-0001-000000038118', '00000000-0000-0000-0000-000000000c02', '70 Christchurch House', 'Flat  / 70 Christchurch House, Christchurch Road, London Greater London SW2 3UA, United Kingdom', 'SW2 3UA', '00000000-0000-0000-0002-000000038118', true, 38118);
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000381180', '00000000-0000-0000-0001-000000038118', 'Whole property', 'flat');
insert into contacts (id, company_id, category, name) values ('00000000-0000-0000-0002-000000038117', '00000000-0000-0000-0000-000000000c02', 'owner', 'Green Light Asset Management Limited');
insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) values ('00000000-0000-0000-0001-000000038117', '00000000-0000-0000-0000-000000000c02', '57B Minet Avenue', 'Flat B / 57 Minet Avenue, London Greater London, United Kingdom', null, '00000000-0000-0000-0002-000000038117', true, 38117);
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000381170', '00000000-0000-0000-0001-000000038117', 'Whole property', 'flat');
insert into contacts (id, company_id, category, name) values ('00000000-0000-0000-0002-000000038116', '00000000-0000-0000-0000-000000000c02', 'owner', 'Green Light Asset Management Limited');
insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) values ('00000000-0000-0000-0001-000000038116', '00000000-0000-0000-0000-000000000c02', '40 Bywater House', 'Flat / 40 Bywater House, Harlinger Street, London Greater London SE18 5SP, United Kingdom', 'SE18 5SP', '00000000-0000-0000-0002-000000038116', true, 38116);
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000381160', '00000000-0000-0000-0001-000000038116', 'Whole property', 'flat');
insert into contacts (id, company_id, category, name) values ('00000000-0000-0000-0002-000000038115', '00000000-0000-0000-0000-000000000c02', 'owner', 'Hyjan Housing');
insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) values ('00000000-0000-0000-0001-000000038115', '00000000-0000-0000-0000-000000000c02', '39 Christchurch House', 'Flat  / 39 Christchurch House, Christchurch Road, London Greater London SW2 3UA, United Kingdom', 'SW2 3UA', '00000000-0000-0000-0002-000000038115', true, 38115);
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000381150', '00000000-0000-0000-0001-000000038115', 'Whole property', 'flat');
insert into contacts (id, company_id, category, name) values ('00000000-0000-0000-0002-000000038105', '00000000-0000-0000-0000-000000000c02', 'owner', 'YSP Investments Limited');
insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) values ('00000000-0000-0000-0001-000000038105', '00000000-0000-0000-0000-000000000c02', '20 Christchurch House', 'Flat  / 20 Christchurch House, Christchurch House, Christchurch Road, London Greater London SW2 3UA, United Kingdom', 'SW2 3UA', '00000000-0000-0000-0002-000000038105', true, 38105);
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000381050', '00000000-0000-0000-0001-000000038105', 'Whole property', 'flat');
insert into contacts (id, company_id, category, name) values ('00000000-0000-0000-0002-000000038104', '00000000-0000-0000-0000-000000000c02', 'owner', 'YSP Housing Limited');
insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) values ('00000000-0000-0000-0001-000000038104', '00000000-0000-0000-0000-000000000c02', '15 Christchurch House', 'Flat / 15 Christchurch House, Christchurch Road, London Greater London SW2 3UA, United Kingdom', 'SW2 3UA', '00000000-0000-0000-0002-000000038104', true, 38104);
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000381040', '00000000-0000-0000-0001-000000038104', 'Whole property', 'flat');
insert into contacts (id, company_id, category, name) values ('00000000-0000-0000-0002-000000038101', '00000000-0000-0000-0000-000000000c02', 'owner', 'Greenlight Empty Homes Limited');
insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) values ('00000000-0000-0000-0001-000000038101', '00000000-0000-0000-0000-000000000c02', '14 Wilson Road', '14 Wilson Road, Westcliff-on-Sea, Southend-on-Sea Southend-on-Sea SS1 1HG, United Kingdom', 'SS1 1HG', '00000000-0000-0000-0002-000000038101', true, 38101);
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000381010', '00000000-0000-0000-0001-000000038101', 'Whole property', 'flat');
insert into contacts (id, company_id, category, name) values ('00000000-0000-0000-0002-000000038058', '00000000-0000-0000-0000-000000000c02', 'owner', 'W Hillard & Co limited');
insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) values ('00000000-0000-0000-0001-000000038058', '00000000-0000-0000-0000-000000000c02', '12 Chaffinch Close', 'Flat / 12 Chaffinch Close, London Greater London N9 8UG, United Kingdom', 'N9 8UG', '00000000-0000-0000-0002-000000038058', true, 38058);
insert into units (id, property_id, name, unit_type) values ('00000000-0000-0000-0003-000000380580', '00000000-0000-0000-0001-000000038058', 'Whole property', 'flat');
with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ('00000000-0000-0000-0001-000000038116', 'Alexander Russell', 'ast', null, 'current', true, 88341) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('00000000-0000-0000-0000-000000000c02', 'Alexander Russell', 'Alexander-russell1@hotmail.co.uk', null) returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = '00000000-0000-0000-0001-000000038116' and u.name = 'Whole property'),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '2025-11-01', null, true, true from t)
insert into charge_schedules (tenancy_id, kind, amount_net, vat_rate, frequency, start_date) select t.id, 'rent', 1400, 0, 'monthly', '2025-11-01' from t;
with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ('00000000-0000-0000-0001-000000038118', 'Charlotte Browne & William Kelly', 'ast', null, 'current', true, 88344) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('00000000-0000-0000-0000-000000000c02', 'Charlotte Browne & William Kelly (Charlotte Browne)', 'charliebrowne7@gmail.com', null) returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = '00000000-0000-0000-0001-000000038118' and u.name = 'Whole property'),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '2016-12-23', null, true, true from t)
insert into charge_schedules (tenancy_id, kind, amount_net, vat_rate, frequency, start_date) select t.id, 'rent', 1650, 0, 'monthly', '2016-12-23' from t;
with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ('00000000-0000-0000-0001-000000038104', 'Elliot Wright', 'ast', null, 'current', true, 88337) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('00000000-0000-0000-0000-000000000c02', 'Elliot Wright', 'ewright1@live.co.uk', null) returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = '00000000-0000-0000-0001-000000038104' and u.name = 'Whole property'),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '2025-04-11', null, true, true from t)
insert into charge_schedules (tenancy_id, kind, amount_net, vat_rate, frequency, start_date) select t.id, 'rent', 1600, 0, 'monthly', '2025-04-11' from t;
with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ('00000000-0000-0000-0001-000000038101', 'Mary Anderson', 'ast', 'Residential Tenancy Agreement', 'current', true, 88324) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('00000000-0000-0000-0000-000000000c02', 'Mary Anderson', 'MaryAnderson142017@gmail.com', '00 44 7920053858') returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = '00000000-0000-0000-0001-000000038101' and u.name = 'Whole property'),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '1996-09-12', null, true, true from t)
insert into charge_schedules (tenancy_id, kind, amount_net, vat_rate, frequency, start_date) select t.id, 'rent', 800, 0, 'monthly', '1996-09-12' from t;
with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ('00000000-0000-0000-0001-000000034544', 'NL', 'other', 'Lease', 'current', false, 79486) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('00000000-0000-0000-0000-000000000c03', 'Natan Lempert Mizrahi', null, null) returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = '00000000-0000-0000-0001-000000034544' and u.name = 'Upper Flat'),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '2025-12-25', '2026-12-24', false, true from t)
select 1 from t;
with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ('00000000-0000-0000-0001-000000038119', 'Noémie Tassinkom', 'ast', null, 'current', true, 88345) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('00000000-0000-0000-0000-000000000c02', 'Noémie Tassinkom', 'Noemie.Tassinkom@gmail.com', null) returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = '00000000-0000-0000-0001-000000038119' and u.name = 'Whole property'),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '2024-04-01', null, true, true from t)
insert into charge_schedules (tenancy_id, kind, amount_net, vat_rate, frequency, start_date) select t.id, 'rent', 1500, 0, 'monthly', '2024-04-01' from t;
with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ('00000000-0000-0000-0001-000000034544', 'NUYU London', 'commercial_lease', 'Lease', 'current', false, 78929) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('00000000-0000-0000-0000-000000000c03', 'Samantha Larkin', 'nuyulondon@gmail.com', null) returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = '00000000-0000-0000-0001-000000034544' and u.name = 'NUYU London'),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '2025-12-25', '2028-12-24', false, true from t)
select 1 from t;
with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ('00000000-0000-0000-0001-000000038236', 'Patrick Schneider and Robin Schneider', 'ast', null, 'current', true, 88702) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('00000000-0000-0000-0000-000000000c02', 'Patrick Schneider and Robin Schneider', null, null) returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = '00000000-0000-0000-0001-000000038236' and u.name = 'Whole property'),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '2026-07-25', null, true, true from t)
insert into charge_schedules (tenancy_id, kind, amount_net, vat_rate, frequency, start_date) select t.id, 'rent', 7000, 0, 'monthly', '2026-07-25' from t;
with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ('00000000-0000-0000-0001-000000034544', 'Richard Dennison', 'other', 'Lease', 'current', false, 79427) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('00000000-0000-0000-0000-000000000c03', 'R Dennison (Richard Dennison)', 'richarddennison@hotmail.com', null) returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = '00000000-0000-0000-0001-000000034544' and u.name = 'Basement Flat'),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '2025-12-25', '2026-12-24', false, true from t)
select 1 from t;
with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ('00000000-0000-0000-0001-000000038058', 'Simon Earles', 'ast', 'Residential Tenancy Agreement', 'current', true, 88263) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('00000000-0000-0000-0000-000000000c02', 'Simon Earles', 'simon.earles1@gmail.com', null) returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = '00000000-0000-0000-0001-000000038058' and u.name = 'Whole property'),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '2024-02-24', null, true, true from t)
insert into charge_schedules (tenancy_id, kind, amount_net, vat_rate, frequency, start_date) select t.id, 'rent', 1000, 0, 'monthly', '2024-02-24' from t;
with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ('00000000-0000-0000-0001-000000038117', 'Tatyana Hamilton', 'ast', null, 'current', true, 88343) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('00000000-0000-0000-0000-000000000c02', 'Tatyana Hamilton', 'tatyanahamilton1234@icloud.com', null) returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = '00000000-0000-0000-0001-000000038117' and u.name = 'Whole property'),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '2025-12-01', '2026-12-01', false, true from t)
insert into charge_schedules (tenancy_id, kind, amount_net, vat_rate, frequency, start_date) select t.id, 'rent', 1685, 0, 'monthly', '2025-12-01' from t;
