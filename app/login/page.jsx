'use client';
import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [state, setState] = useState('idle'); // idle | sending | sent | error
  const [error, setError] = useState('');

  async function onSubmit(e) {
    e.preventDefault();
    setState('sending');
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: {
        emailRedirectTo: `${window.location.origin}/auth/callback`,
        shouldCreateUser: false, // only invited users can sign in
      },
    });
    if (error) {
      setError(error.message);
      setState('error');
    } else {
      setState('sent');
    }
  }

  return (
    <div className="login">
      <h1>Sign in</h1>
      <p className="sub">We'll email you a one-time sign-in link.</p>
      <form onSubmit={onSubmit}>
        <input
          type="email"
          required
          placeholder="you@goldhurstpropertygroup.co.uk"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          autoComplete="email"
        />
        <button type="submit" disabled={state === 'sending'}>
          {state === 'sending' ? 'Sending…' : 'Email me a link'}
        </button>
      </form>
      {state === 'sent' && <div className="notice">Check your inbox for the sign-in link. Open it in this browser.</div>}
      {state === 'error' && <div className="notice">Couldn't send the link: {error}</div>}
    </div>
  );
}
