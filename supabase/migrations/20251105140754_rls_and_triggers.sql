-- 1) Create a profile row automatically when a new user signs up
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.profiles (id, username, display_name, avatar_url)
  values (
    new.id,
    split_part(new.email, '@', 1),
    split_part(new.email, '@', 1),
    null
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- 2) Enable Row Level Security
alter table public.profiles enable row level security;
alter table public.wardrobe_items enable row level security;

-- 3) Profiles — anyone can read; only owner can update their own
drop policy if exists "profiles read all" on public.profiles;
create policy "profiles read all"
on public.profiles for select
using (true);

drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own"
on public.profiles for update
using (auth.uid() = id);

-- 4) Wardrobe items — only owner can CRUD
drop policy if exists "items select own" on public.wardrobe_items;
create policy "items select own"
on public.wardrobe_items for select
using (auth.uid() = user_id);

drop policy if exists "items insert own" on public.wardrobe_items;
create policy "items insert own"
on public.wardrobe_items for insert
with check (auth.uid() = user_id);

drop policy if exists "items update own" on public.wardrobe_items;
create policy "items update own"
on public.wardrobe_items for update
using (auth.uid() = user_id);

drop policy if exists "items delete own" on public.wardrobe_items;
create policy "items delete own"
on public.wardrobe_items for delete
using (auth.uid() = user_id);
