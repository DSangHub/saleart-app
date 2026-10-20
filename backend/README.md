# SaleArt.app PWA Backend

Lightweight backend for the SaleArt Progressive Web App.

## Goals (MVP)
- User accounts (auth)
- Pair and manage e-ink signs
- Store messages / templates
- Generate update payloads the app can send to a sign (NFC / BLE / Wi-Fi)
- Basic history

## Recommended stack
**Supabase** (Postgres + Auth + Storage + Edge Functions)
- Relational data fits users → devices → messages
- Row Level Security keeps users’ signs private
- Free tier is enough for early testing
- Easy to self-host later if needed

Alternative: Firebase (faster realtime, stronger mobile SDKs) if you prefer NoSQL and Google ecosystem.

## Core tables (Supabase / Postgres)

```sql
-- users handled by Supabase Auth

create table devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  name text,
  device_code text unique,          -- printed or QR on the sign
  model text,                       -- rectangular / chat-bubble
  has_tracker boolean default false,
  last_seen timestamptz,
  created_at timestamptz default now()
);

create table messages (
  id uuid primary key default gen_random_uuid(),
  device_id uuid references devices(id) on delete cascade,
  user_id uuid references auth.users(id),
  text text not null,
  font text,
  color text,                       -- limited by e-ink panel
  payload jsonb,                    -- rendered or structured data for the sign
  status text default 'pending',    -- pending / sent / applied
  created_at timestamptz default now()
);

create table templates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  name text,
  text text,
  font text,
  color text,
  created_at timestamptz default now()
);
```

## Update flow (MVP)
1. User types message in PWA.
2. Backend saves the message and returns a compact payload (text + style).
3. PWA sends the payload to the physical sign via:
   - NFC (battery-free small units, phone powers the write)
   - Bluetooth LE
   - Wi-Fi / MQTT (for larger or always-connected units)
4. Sign confirms or the app marks status as sent.

No heavy cloud-to-device push is required for the first version if most updates happen while the user is next to the sign.

## Next steps
1. Create a Supabase project.
2. Run the schema above.
3. Enable Auth (email magic link or Google).
4. Add simple RLS policies (users can only see their own devices/messages).
5. Build the PWA frontend against the Supabase client.

## Environment
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=   # server-side only
```

---
First version focuses on reliable e-ink updates rather than pure magnetic-particle control.
