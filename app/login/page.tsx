'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabaseBrowser } from '../../lib/supabase';

export default function Login() {
  const router = useRouter();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [err, setErr] = useState('');
  const [loading, setLoading] = useState(false);

  async function submit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();

    setErr('');
    setLoading(true);

    try {
      const sb = supabaseBrowser();

      // Sign in with Supabase Auth
      const { data, error } = await sb.auth.signInWithPassword({
        email: email.trim(),
        password,
      });

      if (error) {
        setErr(`Login failed: ${error.message}`);
        setLoading(false);
        return;
      }

      if (!data.user) {
        setErr('Login failed: No user was returned by Supabase.');
        setLoading(false);
        return;
      }

      // Check the user's school portal profile
      const { data: profile, error: profileError } = await sb
        .from('profiles')
        .select('id, full_name, role')
        .eq('id', data.user.id)
        .maybeSingle();

      if (profileError) {
        await sb.auth.signOut();

        setErr(
          `Profile check failed: ${profileError.message}`
        );

        setLoading(false);
        return;
      }

      if (!profile) {
        await sb.auth.signOut();

        setErr(
          'Login successful, but this account has no school admin profile.'
        );

        setLoading(false);
        return;
      }

      // Allow admin and accountant accounts
      if (profile.role !== 'admin' && profile.role !== 'accountant') {
        await sb.auth.signOut();

        setErr(
          `This account is not authorized. Current role: ${profile.role}`
        );

        setLoading(false);
        return;
      }

      // Successful login
      window.location.href = '/admin';

    } catch (error) {
      console.error('LOGIN ERROR:', error);

      setErr(
        error instanceof Error
          ? `Unexpected error: ${error.message}`
          : 'Unexpected login error.'
      );

      setLoading(false);
    }
  }

  return (
    <main className="min-h-[calc(100vh-140px)] bg-slate-50 flex items-center justify-center px-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-sm border border-slate-200 p-7">

        <div className="mb-6">
          <h1 className="text-3xl font-bold text-slate-900">
            Admin Login
          </h1>

          <p className="text-slate-500 mt-2">
            Use your school admin account.
          </p>
        </div>

        <form onSubmit={submit} className="space-y-5">

          <div>
            <label className="block text-sm font-medium text-slate-700 mb-2">
              Email
            </label>

            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@example.com"
              autoComplete="email"
              required
              className="w-full rounded-xl border border-slate-300 px-4 py-3 outline-none focus:border-blue-600 focus:ring-2 focus:ring-blue-100"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700 mb-2">
              Password
            </label>

            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Enter password"
              autoComplete="current-password"
              required
              className="w-full rounded-xl border border-slate-300 px-4 py-3 outline-none focus:border-blue-600 focus:ring-2 focus:ring-blue-100"
            />
          </div>

          {err && (
            <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              <strong>Error:</strong> {err}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-xl bg-blue-900 text-white py-3 font-semibold hover:bg-blue-800 disabled:opacity-60 disabled:cursor-not-allowed"
          >
            {loading ? 'Signing in...' : 'Sign in'}
          </button>

        </form>

      </div>
    </main>
  );
}
