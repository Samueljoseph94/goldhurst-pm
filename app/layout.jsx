import './globals.css';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';

export const metadata = {
  title: 'Goldhurst PM',
  description: 'Goldhurst Property Group property and service-charge management',
};

export default async function RootLayout({ children }) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  return (
    <html lang="en-GB">
      <body>
        <header className="top">
          <div className="inner">
            <Link href="/" className="brand">GOLDHURST<span>PM</span></Link>
            {user && (
              <nav>
                <Link href="/">Portfolio</Link>
                <span className="muted" style={{ color: 'var(--sage)' }}>{user.email}</span>
                <form action="/auth/signout" method="post">
                  <button type="submit">Sign out</button>
                </form>
              </nav>
            )}
          </div>
        </header>
        <main>{children}</main>
      </body>
    </html>
  );
}
