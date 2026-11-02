import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

// The emailed link lands here with ?code=…; swap it for a session, then go to the portfolio.
export async function GET(request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get('code');
  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) return NextResponse.redirect(`${origin}/`);
  }
  return NextResponse.redirect(`${origin}/login?error=link`);
}
