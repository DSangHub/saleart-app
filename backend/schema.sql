-- SaleArt.app Supabase schema
-- Run this in the Supabase SQL editor

-- Enable extensions if needed
create extension if not exists "uuid-ossp";

-- Devices (physical signs)
create table if not exists public.devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text,
  device_code text unique not null,          -- QR or printed code on the sign
  model text default 'rectangular',           -- rectangular | chat-bubble
  has_tracker boolean default false,
  last_seen timestamptz,
  created_at timestamptz default now()
);

-- Messages sent to signs
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  device_id uuid not null references public.devices(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  text text not null,
  font text default 'bold',
  color text default 'black',
  payload jsonb,                              -- structured data for the sign
  status text default 'pending' check (status in ('pending', 'sent', 'applied', 'failed')),
  created_at timestamptz default now()
);

-- Reusable templates
create table if not exists public.templates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  text text not null,
  font text default 'bold',
  color text default 'black',
  created_at timestamptz default now()
);

-- Indexes
create index if not exists idx_devices_user_id on public.devices(user_id);
create index if not exists idx_messages_device_id on public.messages(device_id);
create index if not exists idx_messages_user_id on public.messages(user_id);
create index if not exists idx_templates_user_id on public.templates(user_id);

-- Row Level Security
alter table public.devices enable row level security;
alter table public.messages enable row level security;
alter table public.templates enable row level security;

-- Devices policies
create policy "Users can view own devices"
  on public.devices for select
  using (auth.uid() = user_id);

create policy "Users can insert own devices"
  on public.devices for insert
  with check (auth.uid() = user_id);

create policy "Users can update own devices"
  on public.devices for update
  using (auth.uid() = user_id);

create policy "Users can delete own devices"
  on public.devices for delete
  using (auth.uid() = user_id);

-- Messages policies
create policy "Users can view own messages"
  on public.messages for select
  using (auth.uid() = user_id);

create policy "Users can insert own messages"
  on public.messages for insert
  with check (auth.uid() = user_id);

create policy "Users can update own messages"
  on public.messages for update
  using (auth.uid() = user_id);

-- Templates policies
create policy "Users can view own templates"
  on public.templates for select
  using (auth.uid() = user_id);

create policy "Users can insert own templates"
  on public.templates for insert
  with check (auth.uid() = user_id);

create policy "Users can update own templates"
  on public.templates for update
  using (auth.uid() = user_id);

create policy "Users can delete own templates"
  on public.templates for delete
  using (auth.uid() = user_id);

-- Optional: service role bypass is automatic for admin operations
