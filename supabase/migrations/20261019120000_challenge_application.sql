-- -5kg challenge application form. Assumes profiles is empty (no applicants yet):
-- new required columns have no defaults.
alter table public.profiles
  drop column experience,
  drop column motivation,
  add column nickname text not null check (char_length(nickname) between 1 and 20),
  add column age_group text not null check (age_group in ('early20', 'mid20', 'late20')),
  add column residence text not null check (char_length(residence) between 1 and 40),
  add column activity_level text not null
    check (activity_level in ('breathing', 'walk', 'regular', 'gym')),
  add column temptations text[] not null default '{}'
    check (temptations <@ array['late_snack', 'chicken', 'ramen', 'tteokbokki', 'alcohol',
                                'dessert', 'sweet_drink', 'delivery', 'couch']::text[]),
  add column workouts text[] not null
    check (cardinality(workouts) >= 1
       and workouts <@ array['running', 'gym', 'home', 'jump_rope', 'hiking',
                             'cycling', 'swimming', 'yoga', 'dance']::text[]),
  add column time_slots text[] not null
    check (cardinality(time_slots) >= 1
       and time_slots <@ array['dawn', 'lunch', 'evening', 'night', 'weekend']::text[]),
  add column duration_weeks int not null check (duration_weeks in (4, 6, 8)),
  add column willpower int not null default 5 check (willpower between 1 and 10),
  add column cheer_style text not null check (cheer_style in ('praise', 'roast', 'quiet', 'compete')),
  add column penalty_vote text not null check (penalty_vote in ('fine', 'selfie', 'coffee', 'squat')),
  add column reward text check (char_length(reward) <= 100),
  add column resolution text check (char_length(resolution) <= 300),
  add column health_note text check (char_length(health_note) <= 300),
  add column privacy_consent boolean not null check (privacy_consent);

grant insert (nickname, age_group, residence, activity_level, temptations, workouts, time_slots,
              duration_weeks, willpower, cheer_style, penalty_vote, reward, resolution,
              health_note, privacy_consent)
  on public.profiles to authenticated;

-- Feed shows the chat nickname, not the real name
create or replace function public.feed(max_rows int default 50)
returns table (run_id bigint, runner text, run_date date, km numeric, minutes int, weight numeric, is_mine boolean)
language sql stable security definer set search_path = '' as $$
  select r.id, p.nickname, r.run_date, r.km, r.minutes,
         case when p.weight_public or p.id = (select auth.uid()) then r.weight end,
         p.id = (select auth.uid())
  from public.runs r join public.profiles p on p.id = r.user_id
  where public.is_approved() and p.status = 'approved'
  order by r.run_date desc, r.id desc
  limit least(greatest(max_rows, 1), 200);
$$;
