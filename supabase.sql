-- ============================================================
-- What Was That Called Again? — Supabase schema
-- Run this once in your Supabase project: SQL Editor → New query
-- ============================================================

create table if not exists public.watched (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  imdb_id     text,
  tvmaze_id   integer,
  title       text not null,
  year        text,
  type        text not null default 'movie',          -- 'movie' | 'series'
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
