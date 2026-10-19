begin;
select plan(16);

-- A: approved, weight private · B: approved, weight public · C: pending · D: signed in, no application
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@test.local'),
  ('00000000-0000-0000-0000-00000000000b', 'b@test.local'),
  ('00000000-0000-0000-0000-00000000000c', 'c@test.local'),
  ('00000000-0000-0000-0000-00000000000d', 'd@test.local');
insert into public.profiles (id, name, phone, experience, motivation, status, weight_public) values
  ('00000000-0000-0000-0000-00000000000a', 'A', '0100000000', 'none', 'hi', 'approved', false),
  ('00000000-0000-0000-0000-00000000000b', 'B', '0100000000', 'none', 'hi', 'approved', true),
  ('00000000-0000-0000-0000-00000000000c', 'C', '0100000000', 'none', 'hi', 'pending', false);
insert into public.runs (user_id, run_date, km, minutes, weight) values
  ('00000000-0000-0000-0000-00000000000a', '2026-10-01', 5, 30, 70),
  ('00000000-0000-0000-0000-00000000000b', '2026-10-02', 10, 60, 60),
  ('00000000-0000-0000-0000-00000000000c', '2026-10-03', 3, 20, 80);

create function pg_temp.login(uid text) returns void language sql as $$
  select set_config('role', 'authenticated', true),
         set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

-- anon sees nothing
set local role anon;
select throws_ok('select * from public.profiles', '42501', null, 'anon cannot read profiles');
select throws_ok('select * from public.runs', '42501', null, 'anon cannot read runs');
select throws_ok('select * from public.feed()', '42501', null, 'anon cannot call feed');
reset role;

-- C (pending)
select pg_temp.login('00000000-0000-0000-0000-00000000000c');
select throws_ok($$insert into public.runs (run_date, km, minutes, weight) values ('2026-10-05', 5, 30, 70)$$,
  '42501', null, 'pending member cannot add runs');
select throws_ok($$update public.profiles set status = 'approved'$$,
  '42501', null, 'member cannot approve themselves');
select is((select count(*) from public.feed()), 0::bigint, 'pending member sees empty feed');
reset role;

-- D (no application yet)
select pg_temp.login('00000000-0000-0000-0000-00000000000d');
select throws_ok($$insert into public.profiles (name, phone, experience, motivation, status) values ('D', '0100000000', 'none', 'hi', 'approved')$$,
  '42501', null, 'applicant cannot self-set status');
select lives_ok($$insert into public.profiles (name, phone, experience, motivation) values ('D', '0100000000', 'none', 'hi')$$,
  'applicant can submit application');
select is((select status from public.profiles), 'pending', 'new application is pending');
select throws_ok($$insert into public.profiles (id, name, phone, experience, motivation) values ('00000000-0000-0000-0000-0000000000ee', 'X', '0100000000', 'none', 'hi')$$,
  '42501', null, 'applicant cannot apply for someone else');
reset role;

-- A (approved, private weight)
select pg_temp.login('00000000-0000-0000-0000-00000000000a');
select is((select count(*) from public.runs where user_id <> auth.uid()), 0::bigint, 'member cannot read others runs directly');
select is((select count(*) from public.profiles), 1::bigint, 'member reads only own profile');
select is((select weight from public.feed() where runner = 'B'), 60.0, 'public weight is visible in feed');
select is((select weight from public.feed() where runner = 'A'), 70.0, 'own weight is visible in feed');
select is((select count(*) from public.feed() where runner = 'C'), 0::bigint, 'pending members are not in feed');
reset role;

-- B looks at A's private weight
select pg_temp.login('00000000-0000-0000-0000-00000000000b');
select is((select weight is null from public.feed() where runner = 'A'), true, 'private weight is hidden in feed');
reset role;

select * from finish();
rollback;
