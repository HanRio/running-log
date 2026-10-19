begin;
select plan(20);

-- A: approved, weight private · B: approved, weight public · C: pending · D: signed in, no application
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@test.local'),
  ('00000000-0000-0000-0000-00000000000b', 'b@test.local'),
  ('00000000-0000-0000-0000-00000000000c', 'c@test.local'),
  ('00000000-0000-0000-0000-00000000000d', 'd@test.local');
insert into public.profiles (id, name, nickname, phone, age_group, residence, activity_level, workouts, time_slots,
                             duration_weeks, cheer_style, penalty_vote, privacy_consent, status, weight_public)
select id::uuid, n, 'nick_' || n, '01000000000', 'mid20', '서울 마포구', 'walk', '{running}', '{evening}', 6, 'praise', 'coffee', true, s, w
from (values ('00000000-0000-0000-0000-00000000000a', 'A', 'approved', false),
             ('00000000-0000-0000-0000-00000000000b', 'B', 'approved', true),
             ('00000000-0000-0000-0000-00000000000c', 'C', 'pending', false)) v(id, n, s, w);
insert into public.runs (user_id, run_date, km, minutes, weight) values
  ('00000000-0000-0000-0000-00000000000a', '2026-10-01', 5, 30, 70),
  ('00000000-0000-0000-0000-00000000000b', '2026-10-02', 10, 60, 60),
  ('00000000-0000-0000-0000-00000000000c', '2026-10-03', 3, 20, 80);

create function pg_temp.login(uid text) returns void language sql as $$
  select set_config('role', 'authenticated', true),
         set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

-- A valid application as the browser sends it; tests override single fields
create function pg_temp.apply_sql(overrides text default '') returns text language sql as $$
  select format($f$insert into public.profiles (name, nickname, phone, age_group, residence, activity_level, temptations,
      workouts, time_slots, duration_weeks, willpower, cheer_style, penalty_vote, reward, resolution, health_note,
      privacy_consent %s) values ('D', 'dee', '01012345678', 'early20', '부산 해운대구', 'breathing', '{chicken,couch}',
      '{running,gym}', '{dawn,weekend}', 4, 7, 'roast', 'squat', '청바지', '진짜다', '무릎', %s)$f$,
    case when overrides = '' then '' else ', ' || split_part(overrides, '=', 1) end,
    case when overrides = '' then 'true' else 'true, ' || split_part(overrides, '=', 2) end);
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
select throws_ok(pg_temp.apply_sql('status=''approved'''), '42501', null, 'applicant cannot self-set status');
select throws_ok(pg_temp.apply_sql('id=''00000000-0000-0000-0000-0000000000ee'''), '42501', null,
  'applicant cannot apply for someone else');
select throws_ok(replace(pg_temp.apply_sql(), '''{running,gym}''', '''{}'''), '23514', null,
  'at least one workout is required');
select throws_ok(replace(pg_temp.apply_sql(), '''{chicken,couch}''', '''{pizza}'''), '23514', null,
  'unknown temptation is rejected');
select throws_ok(replace(pg_temp.apply_sql(), ', 4, 7,', ', 5, 7,'), '23514', null,
  'duration must be 4, 6 or 8 weeks');
select throws_ok(regexp_replace(pg_temp.apply_sql(), 'true\)$', 'false)'), '23514', null,
  'privacy consent is required');
select lives_ok(pg_temp.apply_sql(), 'applicant can submit a full application');
select is((select status from public.profiles), 'pending', 'new application is pending');
reset role;

-- A (approved, private weight)
select pg_temp.login('00000000-0000-0000-0000-00000000000a');
select is((select count(*) from public.runs where user_id <> auth.uid()), 0::bigint, 'member cannot read others runs directly');
select is((select count(*) from public.profiles), 1::bigint, 'member reads only own profile');
select is((select weight from public.feed() where runner = 'nick_B'), 60.0, 'feed shows nickname and public weight');
select is((select weight from public.feed() where runner = 'nick_A'), 70.0, 'own weight is visible in feed');
select is((select count(*) from public.feed() where runner = 'nick_C'), 0::bigint, 'pending members are not in feed');
reset role;

-- B looks at A's private weight
select pg_temp.login('00000000-0000-0000-0000-00000000000b');
select is((select weight is null from public.feed() where runner = 'nick_A'), true, 'private weight is hidden in feed');
reset role;

select * from finish();
rollback;
