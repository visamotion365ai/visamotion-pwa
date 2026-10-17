-- VisaMOTion consumer PWA schema.
-- All objects use a product-specific prefix and are safe to apply beside the existing agency tables.
create table if not exists public.visamotion_destinations (
  slug text primary key,
  name text not null,
  code text not null,
  region text not null,
  tagline text not null,
  description text not null,
  eta text,
  fee text,
  gradient text,
  highlights jsonb not null default '[]'::jsonb,
  purposes jsonb not null default '[]'::jsonb,
  requirements jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.visamotion_content (
  key text primary key,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.visamotion_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  phone text,
  origin_country text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.visamotion_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  reference text not null unique,
  destination_slug text not null references public.visamotion_destinations(slug),
  purpose text not null,
  status text not null default 'Draft',
  progress integer not null default 0 check (progress between 0 and 100),
  next_step text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.visamotion_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  application_id uuid not null references public.visamotion_applications(id) on delete cascade,
  label text not null,
  file_name text,
  storage_path text,
  size_bytes bigint,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists visamotion_applications_user_id_idx on public.visamotion_applications(user_id);
create index if not exists visamotion_documents_application_id_idx on public.visamotion_documents(application_id);

alter table public.visamotion_destinations enable row level security;
alter table public.visamotion_content enable row level security;
alter table public.visamotion_profiles enable row level security;
alter table public.visamotion_applications enable row level security;
alter table public.visamotion_documents enable row level security;

drop policy if exists "Public can read VisaMOTion destinations" on public.visamotion_destinations;
create policy "Public can read VisaMOTion destinations" on public.visamotion_destinations for select using (true);
drop policy if exists "Public can read VisaMOTion content" on public.visamotion_content;
create policy "Public can read VisaMOTion content" on public.visamotion_content for select using (true);
drop policy if exists "Members manage own VisaMOTion profile" on public.visamotion_profiles;
create policy "Members manage own VisaMOTion profile" on public.visamotion_profiles for all using (auth.uid() = id) with check (auth.uid() = id);
drop policy if exists "Members manage own VisaMOTion applications" on public.visamotion_applications;
create policy "Members manage own VisaMOTion applications" on public.visamotion_applications for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Members manage own VisaMOTion documents" on public.visamotion_documents;
create policy "Members manage own VisaMOTion documents" on public.visamotion_documents for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

insert into public.visamotion_destinations (slug,name,code,region,tagline,description,eta,fee,gradient,highlights,purposes,requirements) values
('singapore','Singapore','SG','Asia Pacific','Fast-moving, future-ready','A clean, connected launchpad for ambitious careers and global families.','6-10 weeks','from $380','linear-gradient(145deg,#0b989c,#245fe7)','["English-first","Strong tech scene","Family friendly"]','["Work","Study","Business","Family"]','["Passport bio page","Updated CV","Proof of funds","Education records"]'),
('canada','Canada','CA','North America','Room to grow into','A welcoming route for skilled workers, founders, students, and families.','8-14 weeks','from $290','linear-gradient(145deg,#4372c8,#9b574b)','["Express Entry","Post-study work","Clear pathways"]','["Work","Study","Family","Visit"]','["Passport bio page","Language result","Work references","Financial statement"]'),
('portugal','Portugal','PT','Europe','Slow living, smart access','A warm European base with flexible routes for remote work and family life.','4-8 weeks','from $250','linear-gradient(145deg,#e36d4f,#7e52c8)','["Digital nomad","Schengen access","Mild climate"]','["Work","Business","Family","Visit"]','["Passport bio page","Accommodation proof","Income evidence","Insurance cover"]'),
('australia','Australia','AU','Oceania','Build a bigger future','A high-opportunity destination for study, skilled work, and new beginnings.','10-18 weeks','from $420','linear-gradient(145deg,#168d9c,#db9c53)','["Skills pathways","Top universities","Outdoor life"]','["Work","Study","Visit","Family"]','["Passport bio page","Skills assessment","Police certificate","Health cover"]')
on conflict (slug) do update set name=excluded.name,code=excluded.code,region=excluded.region,tagline=excluded.tagline,description=excluded.description,eta=excluded.eta,fee=excluded.fee,gradient=excluded.gradient,highlights=excluded.highlights,purposes=excluded.purposes,requirements=excluded.requirements,updated_at=now();

insert into public.visamotion_content (key,payload) values
('home.hero','{"eyebrow":"VisaMOTion / 01","title":"Your next move, made clear.","body":"Discover the right destination, prepare with confidence, and keep every step in one calm place."}'::jsonb),
('home.install','{"title":"Make VisaMOTion feel like home.","body":"Install it from your browser menu or use Safari Share, then Add to Home Screen on iPhone."}'::jsonb)
on conflict (key) do update set payload=excluded.payload,updated_at=now();

insert into storage.buckets (id,name,public)
values ('visamotion-documents','visamotion-documents',false)
on conflict (id) do nothing;
drop policy if exists "Members upload VisaMOTion documents" on storage.objects;
create policy "Members upload VisaMOTion documents" on storage.objects for insert to authenticated with check (bucket_id = 'visamotion-documents' and (storage.foldername(name))[1] = (select auth.uid()::text));
drop policy if exists "Members read VisaMOTion documents" on storage.objects;
create policy "Members read VisaMOTion documents" on storage.objects for select to authenticated using (bucket_id = 'visamotion-documents' and (storage.foldername(name))[1] = (select auth.uid()::text));
drop policy if exists "Members update VisaMOTion documents" on storage.objects;
create policy "Members update VisaMOTion documents" on storage.objects for update to authenticated using (bucket_id = 'visamotion-documents' and (storage.foldername(name))[1] = (select auth.uid()::text)) with check (bucket_id = 'visamotion-documents' and (storage.foldername(name))[1] = (select auth.uid()::text));
drop policy if exists "Members delete VisaMOTion documents" on storage.objects;
create policy "Members delete VisaMOTion documents" on storage.objects for delete to authenticated using (bucket_id = 'visamotion-documents' and (storage.foldername(name))[1] = (select auth.uid()::text));
