create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'admin' check (role in ('admin','accountant')),
  created_at timestamptz not null default now()
);

create table if not exists public.academic_years (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  start_date date,
  end_date date,
  is_active boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  admission_no text unique not null,
  name text not null,
  class_name text not null,
  section text not null default 'A',
  parent_name text not null default '',
  parent_phone text not null default '',
  parent_email text,
  address text,
  area text,
  sibling_group text,
  hostel_required boolean not null default false,
  vehicle_required boolean not null default false,
  vehicle_area text,
  student_status text not null default 'active' check (student_status in ('active','left','transferred','graduated')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notices (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  category text not null default 'General',
  attachment_url text,
  published boolean not null default false,
  published_at timestamptz,
  expiry_date date,
  created_at timestamptz not null default now()
);

create table if not exists public.fee_structures (
  id uuid primary key default gen_random_uuid(),
  academic_year_id uuid references public.academic_years(id) on delete set null,
  class_name text not null,
  fee_head text not null,
  amount numeric(12,2) not null check (amount >= 0),
  frequency text not null default 'Annual' check (frequency in ('Annual','Monthly','Quarterly','One-time')),
  hostel_only boolean not null default false,
  vehicle_area text,
  created_at timestamptz not null default now(),
  unique(academic_year_id, class_name, fee_head, frequency, vehicle_area)
);

create table if not exists public.student_fee_charges (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  academic_year_id uuid references public.academic_years(id) on delete set null,
  fee_head text not null,
  amount numeric(12,2) not null check (amount >= 0),
  frequency text not null default 'One-time' check (frequency in ('Annual','Monthly','Quarterly','One-time')),
  period text,
  due_date date,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.fee_payments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  fee_head text not null,
  amount numeric(12,2) not null check (amount > 0),
  status text not null default 'paid' check (status in ('paid','due','cancelled','refunded')),
  payment_mode text not null default 'cash' check (lower(payment_mode) = 'cash'),
  receipt_no text unique default ('RCPT-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,10))),
  paid_at timestamptz,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references auth.users(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  details jsonb,
  created_at timestamptz not null default now()
);

alter table public.students add column if not exists parent_email text;
alter table public.students add column if not exists address text;
alter table public.students add column if not exists area text;
alter table public.students add column if not exists sibling_group text;
alter table public.students add column if not exists hostel_required boolean not null default false;
alter table public.students add column if not exists vehicle_required boolean not null default false;
alter table public.students add column if not exists vehicle_area text;
alter table public.students add column if not exists student_status text not null default 'active';
alter table public.students add column if not exists updated_at timestamptz not null default now();
alter table public.fee_payments add column if not exists notes text;
alter table public.fee_structures add column if not exists academic_year_id uuid references public.academic_years(id) on delete set null;
alter table public.fee_structures add column if not exists hostel_only boolean not null default false;
alter table public.fee_structures add column if not exists vehicle_area text;

-- Seed the current academic year only if it does not exist.
insert into public.academic_years(name,start_date,end_date,is_active)
select '2026-27','2026-04-01','2027-03-31',true
where not exists(select 1 from public.academic_years where name='2026-27');

create or replace function public.is_admin()
returns boolean language sql security definer set search_path = public
as $$ select exists(select 1 from public.profiles where id=auth.uid() and role in ('admin','accountant')); $$;

alter table public.profiles enable row level security;
alter table public.students enable row level security;
alter table public.notices enable row level security;
alter table public.fee_payments enable row level security;
alter table public.fee_structures enable row level security;
alter table public.student_fee_charges enable row level security;
alter table public.academic_years enable row level security;
alter table public.audit_logs enable row level security;

drop policy if exists "profiles own" on public.profiles;
create policy "profiles own" on public.profiles for select to authenticated using (id=auth.uid() or public.is_admin());

drop policy if exists "public published notices" on public.notices;
create policy "public published notices" on public.notices for select to anon, authenticated using (published=true and (expiry_date is null or expiry_date >= current_date));
drop policy if exists "admin notices" on public.notices;
create policy "admin notices" on public.notices for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin students" on public.students;
create policy "admin students" on public.students for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin fees" on public.fee_payments;
create policy "admin fees" on public.fee_payments for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin fee structures" on public.fee_structures;
create policy "admin fee structures" on public.fee_structures for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin student charges" on public.student_fee_charges;
create policy "admin student charges" on public.student_fee_charges for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin academic years" on public.academic_years;
create policy "admin academic years" on public.academic_years for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin audit logs" on public.audit_logs;
create policy "admin audit logs" on public.audit_logs for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- After creating the admin user in Supabase Authentication, run:
-- insert into public.profiles(id, full_name, role) values ('AUTH_USER_UUID','School Admin','admin');

alter table public.fee_payments add column if not exists student_fee_charge_id uuid references public.student_fee_charges(id) on delete set null;
