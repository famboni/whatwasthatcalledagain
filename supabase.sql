-- ============================================================
-- What Was That Called Again? — Supabase schema
-- Safe to run repeatedly: existing policies are dropped first.
-- Run once in your Supabase project: SQL Editor → New query
-- ============================================================

create table if not exists public.watched (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  imdb_id     text,
  tvmaze_id   integer,
  title       text not null,
  year        text,
  type        text not null default 'movie',          -- 'movie' | 'series'
  status      text not null default 'watched',     -- 'watched' | 'watching' | 'want'
  poster      text,
  plot        text,
  runtime     text,
  genre       text,
  director    text,
  actors      text,
  imdb_rating text,
  rating      smallint check (rating between 1 and 5), -- your 1-5 stars
  comment     text,
  watched_on  date not null default current_date,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Row Level Security: every user only sees/edits their own rows.
alter table public.watched enable row level security;
-- For existing tables (safe to run repeatedly):
alter table public.watched add column if not exists status text not null default 'watched';


drop policy if exists "own select" on public.watched;
create policy "own select" on public.watched
  for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "own insert" on public.watched;
create policy "own insert" on public.watched
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "own update" on public.watched;
create policy "own update" on public.watched
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "own delete" on public.watched;
create policy "own delete" on public.watched
  for delete to authenticated
  using (auth.uid() = user_id);

create index if not exists watched_user_idx
  on public.watched (user_id, watched_on desc);
create index if not exists watched_user_status_idx
  on public.watched (user_id, status);


-- ============================================================
-- TROUBLESHOOTING — if the app blocks saves with
-- "new row violates row-level security", run this diagnostic
-- (read-only, does not change any data):
-- ============================================================

select
  (select count(*) from pg_policies where schemaname='public' and tablename='watched') as policy_count,
  (select bool_or(policyname='own select') from pg_policies where schemaname='public' and tablename='watched') as has_select,
  (select bool_or(policyname='own insert') from pg_policies where schemaname='public' and tablename='watched') as has_insert,
  (select count(*) from pg_tables where schemaname='public' and tablename='watched') as table_exists;

-- If has_select or has_insert is false → run the main script again.
-- If both are true but the app still blocks saves → the auth user was
-- likely deleted/recreated: sign out of the app and sign back in.

-- Still blocked even though the above looks fine? Inspect the policy details:
select policyname, cmd, roles::text, qual, with_check
from pg_policies
where schemaname = 'public' and tablename = 'watched'
order by policyname;

-- Expected: 4 rows, cmd = SELECT / INSERT / UPDATE / DELETE,
-- roles = {authenticated}, qual = (auth.uid() = user_id),
-- with_check = (auth.uid() = user_id) for INSERT and UPDATE.
-- If roles shows {anon} or qual/with_check differ, delete the bad policy:
--   drop policy if exists "<name>" on public.watched;
-- then re-run the main script.
