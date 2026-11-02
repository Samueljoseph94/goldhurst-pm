import Link from 'next/link';
import { notFound } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { money, date, compareUnits } from '@/lib/format';

export const dynamic = 'force-dynamic';

const ROLE_LABEL = {
  primary_tenant: 'Primary tenant',
  invoice_contact: 'Invoice contact',
  guarantor: 'Guarantor',
  additional: 'Additional',
};

export default async function TenancyPage({ params }) {
  const { id } = await params;
  const supabase = await createClient();

  const { data: t, error } = await supabase
    .from('tenancies')
    .select(`id, name, kind, form, status, reference, notice_months, is_residential, inside_1954_act, released_id,
             property:properties(id, name),
             tenancy_units(unit:units(name, area_sqft)),
             tenancy_contacts(role, contact:contacts(name, email, phone)),
             terms(start_date, end_date, rolling, is_current, break_dates),
             charge_schedules(id, kind, amount_net, vat_rate, frequency, due_day, basis, start_date, end_date, active),
             deposits(amount, held_by, received_on, returned_on)`)
    .eq('id', id)
    .maybeSingle();

  if (error) return <p className="notice">Couldn't load this tenancy: {error.message}</p>;
  if (!t) notFound();

  const units = t.tenancy_units.map((x) => x.unit?.name).filter(Boolean).sort(compareUnits);
  const term = t.terms.find((x) => x.is_current) || t.terms[0];
  const charges = [...t.charge_schedules].sort((a, b) => Number(b.active) - Number(a.active));

  return (
    <>
      <div className="crumbs">
        <Link href="/">Portfolio</Link> / <Link href={`/properties/${t.property.id}`}>{t.property.name}</Link> / {t.name}
      </div>
      <h1>{t.name}</h1>
      <p className="sub">
        {units.join(', ') || 'No unit assigned'} ·{' '}
        <span className={`pill ${t.status === 'expired' ? 'expired' : ''}`}>{t.status.replace('_', ' ')}</span>
      </p>

      <div className="grid2">
        <div className="card">
          <h2 style={{ margin: '14px 14px 0' }}>Tenancy</h2>
          <dl className="kv">
            <dt>Type</dt><dd>{t.kind.replace('_', ' ')}{t.form ? ` · ${t.form}` : ''}</dd>
            <dt>Term</dt>
            <dd>
              {term ? <>{date(term.start_date)} → {term.rolling ? 'rolling' : date(term.end_date)}</> : '—'}
            </dd>
            <dt>Notice</dt><dd>{t.notice_months ? `${t.notice_months} months` : '—'}</dd>
            <dt>Breaks</dt><dd>{term?.break_dates?.length ? term.break_dates.map(date).join(', ') : 'None'}</dd>
            <dt>1954 Act</dt><dd>{t.inside_1954_act ? 'Inside' : 'Outside'}</dd>
            <dt>Residential</dt><dd>{t.is_residential ? 'Yes' : 'No'}</dd>
            <dt>Re-Leased ID</dt><dd className="muted">{t.released_id ?? '—'}</dd>
          </dl>
        </div>

        <div className="card">
          <h2 style={{ margin: '14px 14px 0' }}>Contacts</h2>
          {t.tenancy_contacts.length ? (
            <dl className="kv">
              {t.tenancy_contacts.map((c, i) => (
                <div key={i} style={{ display: 'contents' }}>
                  <dt>{ROLE_LABEL[c.role] || c.role}</dt>
                  <dd>
                    {c.contact?.name}
                    {c.contact?.email && <div><a href={`mailto:${c.contact.email}`}>{c.contact.email}</a></div>}
                    {c.contact?.phone && <div className="muted">{c.contact.phone}</div>}
                  </dd>
                </div>
              ))}
            </dl>
          ) : <div className="empty">No contacts</div>}
        </div>
      </div>

      <h2>Charges</h2>
      <div className="card tablewrap">
        <table>
          <thead>
            <tr>
              <th>Charge</th><th className="num">Net</th><th className="num">VAT</th><th className="num">Gross</th>
              <th>Frequency</th><th>From</th><th>Status</th>
            </tr>
          </thead>
          <tbody>
            {charges.map((c) => {
              const vat = Number(c.amount_net) * Number(c.vat_rate) / 100;
              return (
                <tr key={c.id}>
                  <td>{c.kind.replace('_', ' ')}</td>
                  <td className="num">{money(c.amount_net)}</td>
                  <td className="num">{money(vat)}</td>
                  <td className="num">{money(Number(c.amount_net) + vat)}</td>
                  <td>{c.frequency.replace('_', ' ')}, day {c.due_day}, {c.basis.replace('_', ' ')}</td>
                  <td>{date(c.start_date)}</td>
                  <td><span className={`pill ${c.active ? '' : 'expired'}`}>{c.active ? 'active' : 'ended'}</span></td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <h2>Deposit</h2>
      <div className="card">
        {t.deposits.length ? (
          <dl className="kv">
            {t.deposits.map((d, i) => (
              <div key={i} style={{ display: 'contents' }}>
                <dt>{money(d.amount)}</dt>
                <dd>{d.held_by || '—'} · received {date(d.received_on)}{d.returned_on ? ` · returned ${date(d.returned_on)}` : ''}</dd>
              </div>
            ))}
          </dl>
        ) : <div className="empty">No deposit recorded</div>}
      </div>
    </>
  );
}
