# Goldhurst PM

Goldhurst Property Group's own property and service-charge management platform, built to replace Re-Leased.

**Ground rule:** Xero is the ledger of record. This app creates invoices in Xero and reads payments back. It never keeps its own payments or allocations, which is the cause of Re-Leased's sync errors.

## Stack

- Supabase (Postgres, auth, storage), UK/EU region
- Next.js on Vercel
- Xero API for invoices, bills and payments
- GoCardless for direct debits
- Dropbox Sign for e-signature
- Microsoft 365 for email
- Claude API for document extraction and drafting

## What's here

| Path | Contents |
| --- | --- |
| `supabase/migrations/0001_core.sql` | Companies, contacts, properties, units, tenancies, terms, charge schedules, deposits, Xero cache, arrears view, documents, compliance, reminders, notes, maintenance, key-dates view |
| `supabase/migrations/0002_service_charge.sql` | Service-charge schedules, apportionment, budgets, actuals, demands, year-end reconciliation, caps/collars, reserve funds, s.20 consultations |
| `supabase/migrations/0003_access.sql` | Row-level security: staff by company; `owner_viewer` read-only on their own company |
| `supabase/seed.sql` | Creekside Art Studios, 45 tenancies and 44 units, from Re-Leased on 2 Nov 2026 |
| `tests/service_charge_test.sql` | Hand-checked apportionment, cap, exclusion, management fee and reconciliation case |
| `tests/access_test.sql` | Owner isolation and write blocking |

## Service charge model

1. **Schedule:** a cost pool (Building, Estate, Lift) over a set of units. It is apportioned by floor area, fixed percentage, weighting or equal shares.
2. **Heads of expenditure:** each schedule has heads mapped to Xero account codes, so bill lines flow into actuals automatically.
3. **Year:** a budget per head, with on-account demands raised as Xero invoices (quarterly by default).
4. **Lease terms per tenancy:** a fixed share, an annual cap and collar, and excluded heads. Shares are pro-rated by days occupied. Void shares and cap shortfalls stay with the landlord (`sc_landlord_shortfall`).
5. **Management fee:** added as a percentage of recoverable cost where the leases allow it.
6. **Year-end:** `sc_reconcile(year)` compares actual share with on-account billed. The balance becomes a Xero balancing invoice or credit note.
7. **Reserve funds:** contributions, expenditure and interest, with a running balance per fund.
8. **Residential blocks:** s.20 consultation stages and dates are tracked, and demands flag whether the s.21B summary of rights was attached.

## Run the tests

```
psql -f supabase/migrations/0001_core.sql -f supabase/migrations/0002_service_charge.sql \
     -f supabase/migrations/0003_access.sql -f supabase/seed.sql
psql -f tests/service_charge_test.sql
psql -f tests/access_test.sql
```

## Roadmap

1. Data foundation and Creekside import (this commit)
2. Xero connection: create rent and service-charge invoices, read payments, arrears view
3. Documents: licence templates, e-signature, AI field extraction; key-dates calendar and weekly digest
4. Service-charge screens: budget builder, demand run, actuals from Xero bills, year-end statements
5. Reports: occupiers schedule, arrears, rent paid to date, owner statement, compliance matrix, service-charge statement
6. Owner log-ins, security review, then a pilot alongside Re-Leased
