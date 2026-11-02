import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { money, monthlyEquivalent } from '@/lib/format';

export const dynamic = 'force-dynamic';

export default async function PortfolioPage() {
  const supabase = await createClient();
  const { data: properties, error } = await supabase
    .from('properties')
    .select(`id, name, postcode,
             company:companies(name),
             owner:contacts!properties_owner_contact_id_fkey(name),
             units(id),
             tenancies(id, status, charge_schedules(amount_net, frequency, active))`)
    .order('name');

  if (error) {
    return <p className="notice">Couldn't load the portfolio: {error.message}</p>;
  }
  if (!properties?.length) {
    return (
      <>
        <h1>Portfolio</h1>
        <p className="notice">No properties yet. If you expected to see some, your account may not have been given access to a company.</p>
      </>
    );
  }

  const rows = properties.map((p) => {
    const current = p.tenancies.filter((t) => t.status === 'current' || t.status === 'holding_over');
    const monthly = current.reduce(
      (sum, t) => sum + t.charge_schedules.filter((c) => c.active)
        .reduce((s, c) => s + monthlyEquivalent(c.amount_net, c.frequency), 0),
      0
    );
    return { ...p, currentCount: current.length, monthly };
  });

  const totals = rows.reduce(
    (a, r) => ({ props: a.props + 1, units: a.units + r.units.length, tenancies: a.tenancies + r.currentCount, monthly: a.monthly + r.monthly }),
    { props: 0, units: 0, tenancies: 0, monthly: 0 }
  );

  return (
    <>
      <h1>Portfolio</h1>
      <p className="sub">Every property you have access to, with current tenancies and contracted income.</p>

      <div className="stats">
        <div className="stat"><div className="label">Properties</div><div className="value">{totals.props}</div></div>
        <div className="stat"><div className="label">Units</div><div className="value">{totals.units}</div></div>
        <div className="stat"><div className="label">Current tenancies</div><div className="value">{totals.tenancies}</div></div>
        <div className="stat"><div className="label">Monthly roll (net)</div><div className="value">{money(totals.monthly)}</div></div>
      </div>

      <h2>Properties</h2>
      <div className="card tablewrap">
        <table>
          <thead>
            <tr>
              <th>Property</th><th>Company</th><th>Owner</th>
              <th className="num">Units</th><th className="num">Tenancies</th><th className="num">Monthly (net)</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((p) => (
              <tr key={p.id}>
                <td><Link href={`/properties/${p.id}`}>{p.name}</Link><div className="muted">{p.postcode}</div></td>
                <td>{p.company?.name}</td>
                <td>{p.owner?.name || '—'}</td>
                <td className="num">{p.units.length}</td>
                <td className="num">{p.currentCount}</td>
                <td className="num">{money(p.monthly)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
