create table if not exists public.products (
    slug text primary key,
    name text not null,
    price text not null default '',
    description text not null default '',
    photos jsonb not null default '[]'::jsonb check (jsonb_typeof(photos) = 'array'),
    sort_order integer not null default 0,
    active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists public.admin_users (
    user_id uuid primary key references auth.users (id) on delete cascade
);

alter table public.products enable row level security;
alter table public.admin_users enable row level security;

grant select on public.products to anon, authenticated;
grant insert, update, delete on public.products to authenticated;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
    select exists (
        select 1
        from public.admin_users
        where user_id = (select auth.uid())
    );
$function$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

drop policy if exists "Public can read active products" on public.products;
create policy "Public can read active products"
on public.products
for select
to anon, authenticated
using (active or public.is_admin());

drop policy if exists "Admins can manage products" on public.products;
create policy "Admins can manage products"
on public.products
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

insert into storage.buckets (id, name, public)
values ('product-photos', 'product-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "Anyone can view product photos" on storage.objects;
create policy "Anyone can view product photos"
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'product-photos');

drop policy if exists "Admins can upload product photos" on storage.objects;
create policy "Admins can upload product photos"
on storage.objects
for insert
to authenticated
with check (bucket_id = 'product-photos' and public.is_admin());

drop policy if exists "Admins can update product photos" on storage.objects;
create policy "Admins can update product photos"
on storage.objects
for update
to authenticated
using (bucket_id = 'product-photos' and public.is_admin())
with check (bucket_id = 'product-photos' and public.is_admin());

drop policy if exists "Admins can delete product photos" on storage.objects;
create policy "Admins can delete product photos"
on storage.objects
for delete
to authenticated
using (bucket_id = 'product-photos' and public.is_admin());

insert into public.products (slug, name, price, description, photos, sort_order)
values
    ('frame-kits', 'DIY Frame Kits', '180 pesos', 'Create your own masterpiece with our beginner-friendly wooden frame kits. Includes paint, glue, and decorations.', '[{"src":"images/fram1.jpg","alt":"Art supplies for a DIY frame kit"},{"src":"images/fram2.jpg","alt":"Craft workspace with art materials"},{"src":"images/fram3.jpg","alt":"Paints and brushes for a handmade project"}]'::jsonb, 0),
    ('keychains', 'Personalised Keychains', '35 pesos per pcs', 'Hand-stamped leather or wooden keychains. Add names, dates, or a special message. Perfect little gift.', '[{"src":"images/key2.jpeg","alt":"Handmade personalised keychain"},{"src":"images/key3.jpg","alt":"Handcrafted jewellery and accessories"},{"src":"images/key1.jpeg","alt":"Personal accessories made by hand"},{"src":"images/key4.jpg","alt":"Handmade keychain sample"},{"src":"images/key5.jpg","alt":"Handmade accessory sample"}]'::jsonb, 1),
    ('decoupage-frames', 'Calendar Customized', '150 Pesos', 'Vintage-inspired frames decorated with floral and geometric patterns. Each one is a unique piece.', '[{"src":"images/cal1.jpg","alt":"Decorative frame for decoupage"},{"src":"images/cal2.jpg","alt":"Colourful decorative artwork"},{"src":"images/cal3.jpg","alt":"Art and framed prints"}]'::jsonb, 2),
    ('beaded-charms', 'Beaded Charms', '9.90 Pesos', 'Colourful beaded keychain charms and bag accessories, handmade with love and high-quality beads.', '[{"src":"images/key4.jpg","alt":"Colourful handmade keychain charm"},{"src":"images/key5.jpg","alt":"Handmade accessory sample"}]'::jsonb, 3),
    ('customized-ballpen', 'Customized Ballpen', '3pcs for 75 pesos', 'A personalized ballpen made with a name, message, or design of your choice.', '[{"src":"images/pen0.jpg","alt":"Customized ballpen"},{"src":"images/pen1.jpg","alt":"Ballpen sample 1"},{"src":"images/pen2.jpg","alt":"Ballpen sample 2"},{"src":"images/pen3.jpg","alt":"Ballpen sample 3"},{"src":"images/pen4.jpg","alt":"Ballpen sample 4"}]'::jsonb, 4),
    ('personalized-chipbag', 'Personalized Chip Bag', '65 Per Set', 'Custom snack packaging personalized for birthdays, celebrations, and special events.', '[{"src":"images/chip1.jpg","alt":"Personalized chip bag sample"},{"src":"images/chip2.jpg","alt":"Personalized chip bag sample 2"},{"src":"images/chip3.jpg","alt":"Personalized chip bag sample 3"},{"src":"images/chip4.jpg","alt":"Personalized chip bag sample 4"}]'::jsonb, 5),
    ('efficascent-roll-on', 'Efficascent Roll-On', '90 Pesos', 'A handy roll-on comfort product that is easy to carry in a bag or keep at home.', '[{"src":"images/rol0.jpg","alt":"Efficascent roll-on sample"},{"src":"images/rol1.jpg","alt":"Roll-on product sample 1"},{"src":"images/rol2.jpg","alt":"Roll-on product sample 2"},{"src":"images/rol3.jpg","alt":"Roll-on product sample 3"},{"src":"images/rol4.jpg","alt":"Roll-on product sample 4"}]'::jsonb, 6),
    ('sign-pen', 'Pen Organizer Personalized', '90 Pesos', 'A smooth-writing pen for signatures, notes, and everyday writing.', '[{"src":"images/box1.jpg","alt":"Personalized pen organizer"}]'::jsonb, 7)
on conflict (slug) do nothing;
insert into public.admin_users (user_id)
select id
from auth.users
where email = 'YOUR_ADMIN_EMAIL'
on conflict (user_id) do nothing;