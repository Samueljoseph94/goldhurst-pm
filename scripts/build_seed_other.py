"""Build supabase/seed_other.sql: Hyjan and Goldhurst PM Limited, from the Re-Leased extract of 2 Nov 2026.

Rules applied:
- Archived duplicate properties in Re-Leased are skipped.
- A term whose fixed end date has passed is treated as a rolling (periodic) tenancy.
- Residential rents carry 0% VAT.
- Leases with no rent in Re-Leased are imported without a charge schedule.
"""
import json
from datetime import date

TODAY = date(2026, 11, 2)
PROPS = json.load(open('scripts/data/released_properties_other.json'))
LEASES = json.load(open('scripts/data/released_leases_other.json'))

COMPANY = {
    'Hyjan': '00000000-0000-0000-0000-000000000c02',
    'Goldhurst PM Limited': '00000000-0000-0000-0000-000000000c03',
}
UNITS = {34544: ['Upper Flat', 'NUYU London', 'Basement Flat']}   # 9 Princess Road
KIND = {78929: 'commercial_lease'}                                 # NUYU London, retail


def q(s):
    return 'null' if s in (None, '') else "'" + str(s).replace("'", "''") + "'"


def d(s):
    if not s:
        return None
    dd, mm, yy = s.split('/')
    return date(int(yy), int(mm), int(dd))


def uid(prefix, n):
    return f"'00000000-0000-0000-{prefix}-{str(n).zfill(12)}'"


out = ['-- Hyjan and Goldhurst PM Limited, imported from Re-Leased on 2 Nov 2026']
for name, cid in COMPANY.items():
    out.append(f"insert into companies (id, name) values ('{cid}', {q(name)}) on conflict (id) do nothing;")

for p in PROPS:
    pid, company, title, owner, postcode, address, res = p
    cid = COMPANY[company]
    out.append(f"insert into contacts (id, company_id, category, name) values ({uid('0002', pid)}, '{cid}', 'owner', {q(owner)});")
    out.append(
        f"insert into properties (id, company_id, name, address, postcode, owner_contact_id, is_residential, released_id) "
        f"values ({uid('0001', pid)}, '{cid}', {q(title)}, {q(address)}, {q(postcode)}, {uid('0002', pid)}, {str(res).lower()}, {pid});")
    for i, u in enumerate(UNITS.get(pid, ['Whole property'])):
        out.append(f"insert into units (id, property_id, name, unit_type) values ({uid('0003', pid * 10 + i)}, {uid('0001', pid)}, {q(u)}, "
                   f"{q('flat' if res else 'unit')});")

for l in LEASES:
    pid = l['pid']
    prop = next(p for p in PROPS if p[0] == pid)
    cid, res = COMPANY[prop[1]], prop[6]
    start, end = d(l['start']), d(l['end'])
    end_eff = end if end and end > TODAY else None
    kind = KIND.get(l['id'], 'ast' if res else 'other')
    unit = l['areas'][0] if l['areas'] else 'Whole property'
    c = l['contacts'][0] if l['contacts'] else [l['name'], None, None]
    vat = 0 if res else 20
    charge = ''
    if l['amt']:
        charge = (f"\ninsert into charge_schedules (tenancy_id, kind, amount_net, vat_rate, frequency, start_date) "
                  f"select t.id, 'rent', {l['amt']}, {vat}, 'monthly', '{start}' from t;")
    else:
        charge = '\nselect 1 from t;'
    out.append(f"""with t as (insert into tenancies (property_id, name, kind, form, status, is_residential, released_id)
  values ({uid('0001', pid)}, {q(l['name'])}, '{kind}', {q(l['form'])}, 'current', {str(res).lower()}, {l['id']}) returning id),
c as (insert into contacts (company_id, name, email, phone) values ('{cid}', {q(c[0])}, {q(c[1])}, {q(c[2])}) returning id),
tc as (insert into tenancy_contacts (tenancy_id, contact_id, role) select t.id, c.id, 'primary_tenant' from t, c),
tu as (insert into tenancy_units (tenancy_id, unit_id) select t.id, u.id from t, units u where u.property_id = {uid('0001', pid)} and u.name = {q(unit)}),
tm as (insert into terms (tenancy_id, start_date, end_date, rolling, is_current) select t.id, '{start}', {q(end_eff)}, {str(end_eff is None).lower()}, true from t){charge}""")

open('supabase/seed_other.sql', 'w').write('\n'.join(out) + '\n')
print(len(PROPS), 'properties,', len(LEASES), 'tenancies')
