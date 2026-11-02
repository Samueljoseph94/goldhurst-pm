import Link from 'next/link';
import { notFound } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { money, date, compareUnits, monthlyEquivalent } from '@/lib/format';

export const dynamic = 'force-dynamic';

const STATUS_ORDER = { current: 0, holding_over: 1, vacating: 2, future: 3, expired: 4 };

export default async function PropertyPage({ params }) {
  const { id } = await params;
  const supabase = await createClient();

  const { data: p, error } = await supabase
    .from('properties')
    .select(`id, name, address, postcode,
             company:companies(name),
             owner:contacts!properties_owner_contact_id_fkey(name),
             units(id, name, unit_type, area_sqft),
             tenancies(id, name, status, form,
                       tenancy_units(unit:units(id, name)),
                       tenancy_contacts(role, contact:contacts(name, email)),
                       terms(start_date, end_date, rolling, is_current),
                       charge_schedules(amount_net, vat_rate, frequency, kind, active))`)
    .eq('id', id)
    .maybeSingle();

  if (error) return <p className="notice">Couldn't load this property: {error.message}</p>;
  if (!p) notFound();

  const tenancies = p.tenancies.map((t) => {
    const units = t.tenancy_units.map((tu) => tu.unit?.name).filter(Boolean).sort(compareUnits);
    const term = t.terms.find((x) => x.is_current) || t.terms[0];
    const primary = t.tenancy_contacts.find((c) => c.role === 'primary_tenant')?.contact;
    const monthly = t.charge_schedules.filter((c) => c.active)
      .reduce((s, c) => s + monthlyEquivalent(c.amount_net, c.frequency), 0);
    return { ...t, units, term, primary, monthly, sortUnit: units[0] || '' };
  }).sort((a, b) =>
    (STATUS_ORDER[a.status] - STATUS_ORDER[b.status]) || compareUnits(a.sortUnit, b.sortUnit)
  );

  const occupied = new Set(
    p.tenancies.filter((t) => t.status !== 'expired')
      .flatMap((t) => t.tenancy_units.map((tu) => tu.unit?.id))
  );
  const vacant = p.units.filter((u) => !occupied.has(u.id)).sort((a, b) => compareUnits(a.name, b.name));
  const current = tenancies.filter((t) => t.status !== 'expired');
  const monthly = current.reduce((s, t) => s + t.monthly, 0);

  return (
    <>
      <div className="crumbs"><Link href="/">Portfolio</Link> / {p.name}</div>
      <h1>{p.name}</h1>
      <p className="sub">{[p.address, p.postcode].filter(Boolean).join(', ')} · {p.company?.name} · Owner: {p.owner?.name || '—'}</p>

      <div className="stats">
        <div className="stat"><div className="label">Units</div><div className="value">{p.units.length}</div></div>
        <div className="stat"><div className="label">Let</div><div className="value">{p.units.length - vacant.length}</div></div>
        <div className="stat"><div className="label">Vacant</div><div className="value">{vacant.length}</div></div>
        <div className="stat"><div className="label">Monthly roll (net)</div><div className="value">{money(monthly)}</div></div>
      </div>

      <h2>Tenancies</h2>
      <div className="card tablewrap">
        <table>
          <thead>
            <tr>
              <th>Unit</th><th>Occupier</th><th>Status</th><th>Form</th>
              <th>Start</th><th className="num">Monthly (net)</th><th>Contact</th>
            </tr>
          </thead>
          <tbody>
            {tenancies.map((t) => (
              <tr key={t.id}>
                <td>{t.units.join(', ') || '—'}</td>
                <td><Link href={`/tenancies/${t.id}`}>{t.name}</Link></td>
                <td><span className={`pill ${t.status === 'expired' ? 'expired' : ''}`}>{t.status.replace('_', ' ')}</span></td>
                <td className="muted">{t.form || '—'}</td>
                <td>{date(t.term?.start_date)}</td>
                <td className="num">{money(t.monthly)}</td>
                <td className="muted">{t.primary?.email || '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {vacant.length > 0 && (
        <>
          <h2>Vacant units</h2>
          <div className="card tablewrap">
            <table>
              <thead><tr><th>Unit</th><th>Type</th><th className="num">Area (sq ft)</th></tr></thead>
              <tbody>
                {vacant.map((u) => (
                  <tr key={u.id}><td>{u.name}</td><td className="muted">{u.unit_type || '—'}</td><td className="num">{u.area_sqft ?? '—'}</td></tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </>
  );
}
