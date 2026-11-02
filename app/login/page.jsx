'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  async function onSubmit(e) {
    e.preventDefault();
    setBusy(true);
    setError('');
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) {
      setError(error.message === 'Invalid login credentials' ? 'Email or password not recognised.' : error.message);
      setBusy(false);
    } else {
      router.replace('/');
      router.refresh();
    }
  }

  return (
    <div className="login">
      <h1>Sign in</h1>
      <p className="sub">Goldhurst Property Group</p>
      <form onSubmit={onSubmit}>
        <input
          type="email"
          required
          placeholder="you@goldhurstpropertygroup.co.uk"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          autoComplete="username"
        />
        <input
          type="password"
          required
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          autoComplete="current-password"
          style={{ marginTop: 10 }}
        />
        <button type="submit" disabled={busy}>{busy ? 'Signing in…' : 'Sign in'}</button>
      </form>
      {error && <div className="notice">{error}</div>}
    </div>
  );
}
