import { createBrowserClient } from '@supabase/ssr';

// Supabase public configuration
// Publishable key is intended for browser-side use.
// NEVER put the secret/service-role key here.

const SUPABASE_URL = 'https://bnmwkuiaueevkpqgmfxk.supabase.co';

const SUPABASE_ANON_KEY =
  'sb_publishable_1X-53XGjZwcfiQQw2FFCrg_niG2kgNF';

export function supabaseBrowser() {
  return createBrowserClient(
    SUPABASE_URL,
    SUPABASE_ANON_KEY
  );
}
