import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

// Email links land here with ?token_hash=…&type=… . Unlike the ?code= flow this works even
// when the link is opened in a different browser from the one that asked for it.
export async function GET(request) {
  const { searchParams, origin } = new URL(request.url);
  const token_hash = searchParams.get('token_hash');
  const type = searchParams.get('type') || 'email';
  if (token_hash) {
    const supabase = await createClient();
    const { error } = await supabase.auth.verifyOtp({ token_hash, type });
    if (!error) return NextResponse.redirect(`${origin}/`);
  }
  return NextResponse.redirect(`${origin}/login?error=link`);
}
