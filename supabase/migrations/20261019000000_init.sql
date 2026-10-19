create table public.profiles (
  id uuid primary key default auth.uid() references auth.users on delete cascade,
  name text not null check (char_length(name) between 1 and 40),
  phone text not null check (char_length(phone) between 7 and 20),
  experience text not null check (experience in ('none','lt1','1to3','gt3')),
  motivation text not null check (char_length(motivation) between 1 and 1000),
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  weight_public boolean not null default false,
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
create policy "own profile read" on public.profiles for select to authenticated
  using ((select auth.uid()) = id);
create policy "apply once" on public.profiles for insert to authenticated
  with check ((select auth.uid()) = id and status = 'pending' and weight_public = false);
create policy "own profile update" on public.profiles for update to authenticated
  using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
revoke all on public.profiles from anon;
revoke insert, update, delete on public.profiles from authenticated;
grant insert (name, phone, experience, motivation) on public.profiles to authenticated;
-- status is changed only by the operator (dashboard / service role)
grant update (weight_public) on public.profiles to authenticated;

create function public.is_approved() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles
                 where id = (select auth.uid()) and status = 'approved');
$$;

create table public.runs (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references public.profiles on delete cascade,
  run_date date not null,
  km numeric(5,2) not null check (km > 0 and km <= 500),
  minutes int not null check (minutes between 1 and 2000),
  weight numeric(4,1) not null check (weight between 20 and 300),
  created_at timestamptz not null default now()
);
create index on public.runs (user_id);
create index on public.runs (run_date desc, id desc);
alter table public.runs enable row level security;
create policy "own runs read" on public.runs for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "approved insert" on public.runs for insert to authenticated
  with check ((select auth.uid()) = user_id and public.is_approved());
create policy "own runs delete" on public.runs for delete to authenticated
  using ((select auth.uid()) = user_id);
revoke all on public.runs from anon;
revoke insert, update on public.runs from authenticated;
grant insert (run_date, km, minutes, weight) on public.runs to authenticated;

-- Member feed: approved members only; weight hidden unless the runner made it public
create function public.feed(max_rows int default 50)
returns table (run_id bigint, runner text, run_date date, km numeric, minutes int, weight numeric, is_mine boolean)
language sql stable security definer set search_path = '' as $$
  select r.id, p.name, r.run_date, r.km, r.minutes,
         case when p.weight_public or p.id = (select auth.uid()) then r.weight end,
         p.id = (select auth.uid())
  from public.runs r join public.profiles p on p.id = r.user_id
  where public.is_approved() and p.status = 'approved'
  order by r.run_date desc, r.id desc
  limit least(greatest(max_rows, 1), 200);
$$;
revoke execute on function public.is_approved() from public, anon;
revoke execute on function public.feed(int) from public, anon;
grant execute on function public.is_approved() to authenticated;
grant execute on function public.feed(int) to authenticated;
