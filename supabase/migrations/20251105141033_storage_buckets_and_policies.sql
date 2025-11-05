-- ===============================
-- Storage buckets + RLS policies
-- ===============================

-- Create buckets via direct INSERT (portable on any project)
-- 'wardrobe' and 'outfits' are private; 'avatars' can be public
insert into storage.buckets (id, name, public)
values
  ('wardrobe', 'wardrobe', false),
  ('outfits',  'outfits',  false),
  ('avatars',  'avatars',  true)
on conflict (id) do nothing;

-- ===== Storage RLS policies on storage.objects =====
-- Convention: file keys (name) start with the user's auth UID (36 chars)
-- e.g. `${auth.uid}/${uuid}.jpg`
-- We check: substring(name from 1 for 36) = auth.uid()

-- ---- Wardrobe (private) ----
drop policy if exists "wardrobe read own" on storage.objects;
create policy "wardrobe read own"
on storage.objects for select
using (
  bucket_id = 'wardrobe'
  and substring(name from 1 for 36) = auth.uid()::text
);

drop policy if exists "wardrobe write own" on storage.objects;
create policy "wardrobe write own"
on storage.objects for insert
with check (
  bucket_id = 'wardrobe'
  and substring(name from 1 for 36) = auth.uid()::text
);

drop policy if exists "wardrobe update own" on storage.objects;
create policy "wardrobe update own"
on storage.objects for update
using (
  bucket_id = 'wardrobe'
  and substring(name from 1 for 36) = auth.uid()::text
)
with check (
  bucket_id = 'wardrobe'
  and substring(name from 1 for 36) = auth.uid()::text
);

drop policy if exists "wardrobe delete own" on storage.objects;
create policy "wardrobe delete own"
on storage.objects for delete
using (
  bucket_id = 'wardrobe'
  and substring(name from 1 for 36) = auth.uid()::text
);

-- ---- Outfits (private) ----
drop policy if exists "outfits read own" on storage.objects;
create policy "outfits read own"
on storage.objects for select
using (
  bucket_id = 'outfits'
  and substring(name from 1 for 36) = auth.uid()::text
);

drop policy if exists "outfits write own" on storage.objects;
create policy "outfits write own"
on storage.objects for insert
with check (
  bucket_id = 'outfits'
  and substring(name from 1 for 36) = auth.uid()::text
);

drop policy if exists "outfits update own" on storage.objects;
create policy "outfits update own"
on storage.objects for update
using (
  bucket_id = 'outfits'
  and substring(name from 1 for 36) = auth.uid()::text
)
with check (
  bucket_id = 'outfits'
  and substring(name from 1 for 36) = auth.uid()::text
);

drop policy if exists "outfits delete own" on storage.objects;
create policy "outfits delete own"
on storage.objects for delete
using (
  bucket_id = 'outfits'
  and substring(name from 1 for 36) = auth.uid()::text
);

-- ---- Avatars (public bucket) ----
-- Public URLs can fetch files without auth, but if you query storage.objects
-- via SQL/SDK, this policy allows read for everyone.
drop policy if exists "avatars read all" on storage.objects;
create policy "avatars read all"
on storage.objects for select
using (bucket_id = 'avatars');

drop policy if exists "avatars write own" on storage.objects;
create policy "avatars write own"
on storage.objects for insert
with check (
  bucket_id = 'avatars'
  and substring(name from 1 for 36) = auth.uid()::text
);

drop policy if exists "avatars update own" on storage.objects;
create policy "avatars update own"
on storage.objects for update
using (
  bucket_id = 'avatars'
  and substring(name from 1 for 36) = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and substring(name from 1 for 36) = auth.uid()::text
);

drop policy if exists "avatars delete own" on storage.objects;
create policy "avatars delete own"
on storage.objects for delete
using (
  bucket_id = 'avatars'
  and substring(name from 1 for 36) = auth.uid()::text
);
