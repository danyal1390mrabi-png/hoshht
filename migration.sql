-- ============================================================
-- migration.sql
-- این اسکریپت را یک‌بار در Supabase SQL Editor پروژه‌ات اجرا کن
-- (Project → SQL Editor → New query → پیست کن → Run)
-- ============================================================

-- 1) اضافه کردن ستون‌های جدید به جدول‌های موجود
alter table messages add column if not exists username text;
alter table messages add column if not exists is_bot boolean default false;
alter table messages add column if not exists bot_id text;

alter table rooms add column if not exists ai_bot_id text;

-- 2) جدول جدید برای پیام‌های خصوصی (شخص‌به‌شخص و شخص‌به‌هوش‌مصنوعی)
create table if not exists private_messages (
  id bigserial primary key,
  dm_key text not null,
  sender_username text not null,
  sender_name text,
  receiver_username text,
  text text,
  image_path text,
  audio_path text,
  is_bot boolean default false,
  bot_id text,
  created_at timestamptz default now()
);
create index if not exists idx_private_messages_dmkey on private_messages(dm_key);

-- 3) دسترسی (RLS)
-- اگر روی جدول‌های messages/rooms/users در پروژه‌ات RLS خاموش است (که با توجه
-- به اینکه اپ فعلی بدون لاگین Supabase کار می‌کند، به‌احتمال زیاد همینطور است)،
-- همین را برای جدول جدید هم انجام بده تا رفتار یکسان بماند:
alter table private_messages disable row level security;

-- اگر ترجیح می‌دهی RLS را روشن نگه‌داری و به‌جایش Policy عمومی بدهی، این را
-- به‌جای خط بالا اجرا کن:
-- alter table private_messages enable row level security;
-- create policy "anon full access" on private_messages
--   for all using (true) with check (true);

-- 4) فعال‌سازی Realtime برای جدول جدید (در بخش Database → Replication پروژه،
-- جدول private_messages را هم مثل messages به لیست publication اضافه کن؛
-- یا با همین دستور SQL):
alter publication supabase_realtime add table private_messages;
