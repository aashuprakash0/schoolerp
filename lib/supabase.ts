import { createBrowserClient } from '@supabase/ssr';

// Supabase public configuration
// These values are safe to use in browser-side code.
// NEVER put the service-role key here.

const SUPABASE_URL = 'PASTE_YOUR_SUPABASE_PROJECT_URL_HERE';

const SUPABASE_ANON_KEY = 'PASTE_YOUR_SUPABASE_ANON_KEY_HERE';

export function supabaseBrowser() {
  return createBrowserClient(
    SUPABASE_URL,
    SUPABASE_ANON_KEY
  );
}
