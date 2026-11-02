const gbp = new Intl.NumberFormat('en-GB', { style: 'currency', currency: 'GBP' });

export function money(n) {
  if (n === null || n === undefined || n === '') return '—';
  return gbp.format(Number(n));
}

export function date(d) {
  if (!d) return '—';
  const [y, m, day] = String(d).slice(0, 10).split('-');
  return `${day}/${m}/${y}`;
}

// Studio names like "Studio 27 (Pi)" sort by their number, then the rest.
export function unitSortKey(name = '') {
  const m = name.match(/(\d+)/);
  return m ? [0, Number(m[1]), name] : [1, 0, name];
}

export function compareUnits(a, b) {
  const ka = unitSortKey(a), kb = unitSortKey(b);
  for (let i = 0; i < 3; i++) {
    if (ka[i] < kb[i]) return -1;
    if (ka[i] > kb[i]) return 1;
  }
  return 0;
}

export function monthlyEquivalent(amount, frequency) {
  const n = Number(amount) || 0;
  switch (frequency) {
    case 'weekly': return (n * 52) / 12;
    case 'quarterly':
    case 'usual_quarter_days': return n / 3;
    case 'half_yearly': return n / 6;
    case 'annually': return n / 12;
    default: return n;
  }
}
