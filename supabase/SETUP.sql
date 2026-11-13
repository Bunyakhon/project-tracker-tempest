-- PROJECT TRACKER TEMPEST — NEW SUPABASE PROJECT SETUP
-- Run this script once in YOUR OWN Supabase project's SQL Editor.
-- Empty starter: it DOES NOT import other users' projects, weeks, tasks or evidence.
-- PUBLIC READ: all visitors can read project/week/task text and notes.
-- PRIVATE EVIDENCE: signed-in users can view files; only editors upload/delete.
-- EDITORS: Supabase owner whitelists users manually after sign-up (see SETUP.md).

begin;

create table if not exists public.tracker_editors (
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.tracker_editors enable row level security;
revoke all on public.tracker_editors from anon, authenticated;
grant select on public.tracker_editors to authenticated;
create policy "editor_can_read_own_membership"
  on public.tracker_editors for select to authenticated
  using (user_id = (select auth.uid()));

create table if not exists public.tracker_custom_projects (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(btrim(name)) between 1 and 120),
  description text not null default '' check (length(description) <= 2000),
  planned_weeks integer not null check (planned_weeks between 1 and 104),
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.tracker_custom_weeks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.tracker_custom_projects(id) on delete cascade,
  position integer not null check (position between 1 and 104),
  title text not null check (length(btrim(title)) between 1 and 160),
  goal text not null default '' check (length(goal) <= 3000),
  together text not null default '' check (length(together) <= 3000),
  deliverable text not null default '' check (length(deliverable) <= 3000),
  created_at timestamptz not null default now(),
  unique (project_id, position)
);
create index if not exists tracker_custom_weeks_project_idx
  on public.tracker_custom_weeks (project_id, position);

create table if not exists public.tracker_custom_tasks (
  id uuid primary key default gen_random_uuid(),
  week_id uuid not null references public.tracker_custom_weeks(id) on delete cascade,
  position integer not null check (position between 1 and 99999),
  reference text not null default '' check (length(reference) <= 100),
  title text not null check (length(btrim(title)) between 1 and 250),
  role text not null default '' check (length(role) <= 150),
  description text not null default '' check (length(description) <= 15000),
  details jsonb not null default '[]'::jsonb check (jsonb_typeof(details) = 'array'),
  status text not null default 'not_started'
    check (status in ('not_started', 'in_progress', 'completed')),
  note text not null default '' check (length(note) <= 10000),
  updated_at timestamptz not null default now()
);
create index if not exists tracker_custom_tasks_week_idx
  on public.tracker_custom_tasks (week_id, position);

-- RESTRICT protects against orphaned storage files. Delete evidence files first.
create table if not exists public.tracker_custom_evidence (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tracker_custom_tasks(id) on delete restrict,
  file_path text not null unique check (length(file_path) between 10 and 500),
  file_name text not null check (length(file_name) between 1 and 250),
  mime_type text not null check (mime_type in ('image/jpeg','image/png','image/webp')),
  bytes bigint not null check (bytes between 1 and 5242880),
  caption text not null default '' check (length(caption) <= 500),
  uploaded_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now()
);
create index if not exists tracker_custom_evidence_task_idx
  on public.tracker_custom_evidence (task_id, created_at);

alter table public.tracker_custom_projects enable row level security;
alter table public.tracker_custom_weeks enable row level security;
alter table public.tracker_custom_tasks enable row level security;
alter table public.tracker_custom_evidence enable row level security;

revoke all on public.tracker_custom_projects, public.tracker_custom_weeks,
  public.tracker_custom_tasks, public.tracker_custom_evidence from anon, authenticated;

grant select on public.tracker_custom_projects, public.tracker_custom_weeks,
  public.tracker_custom_tasks to anon, authenticated;
grant insert, update, delete on public.tracker_custom_projects, public.tracker_custom_weeks,
  public.tracker_custom_tasks to authenticated;
grant select, insert, update, delete on public.tracker_custom_evidence to authenticated;

create policy "public_projects_read"
  on public.tracker_custom_projects for select to anon, authenticated using (true);
create policy "public_weeks_read"
  on public.tracker_custom_weeks for select to anon, authenticated using (true);
create policy "public_tasks_read"
  on public.tracker_custom_tasks for select to anon, authenticated using (true);
create policy "signed_in_evidence_read"
  on public.tracker_custom_evidence for select to authenticated using (true);

-- Only editors can write. Visitors who sign up become viewers until whitelisted.
create policy "editor_projects_insert" on public.tracker_custom_projects
  for insert to authenticated
  with check (
    exists (select 1 from public.tracker_editors where user_id = (select auth.uid()))
    and created_by = (select auth.uid())
  );
create policy "editor_projects_update" on public.tracker_custom_projects
  for update to authenticated
  using (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())))
  with check (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())));
create policy "editor_projects_delete" on public.tracker_custom_projects
  for delete to authenticated
  using (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())));

create policy "editor_weeks_insert" on public.tracker_custom_weeks
  for insert to authenticated
  with check (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())));
create policy "editor_weeks_update" on public.tracker_custom_weeks
  for update to authenticated
  using (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())))
  with check (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())));
create policy "editor_weeks_delete" on public.tracker_custom_weeks
  for delete to authenticated
  using (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())));

create policy "editor_tasks_insert" on public.tracker_custom_tasks
  for insert to authenticated
  with check (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())));
create policy "editor_tasks_update" on public.tracker_custom_tasks
  for update to authenticated
  using (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())))
  with check (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())));
create policy "editor_tasks_delete" on public.tracker_custom_tasks
  for delete to authenticated
  using (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())));

create policy "editor_evidence_insert" on public.tracker_custom_evidence
  for insert to authenticated
  with check (
    exists (select 1 from public.tracker_editors where user_id = (select auth.uid()))
    and uploaded_by = (select auth.uid())
    and split_part(file_path, '/', 1) = task_id::text
  );
create policy "editor_evidence_update" on public.tracker_custom_evidence
  for update to authenticated
  using (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())))
  with check (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())));
create policy "editor_evidence_delete" on public.tracker_custom_evidence
  for delete to authenticated
  using (exists (select 1 from public.tracker_editors where user_id = (select auth.uid())));

insert into storage.buckets(id, name, public, file_size_limit, allowed_mime_types)
values (
  'fitm-evidence', 'fitm-evidence', false, 5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict(id) do nothing;

create policy "tempest_signed_in_file_read" on storage.objects
  for select to authenticated
  using (bucket_id = 'fitm-evidence');
create policy "tempest_editor_file_upload" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'fitm-evidence'
    and exists (select 1 from public.tracker_editors where user_id = (select auth.uid()))
    and exists (
      select 1 from public.tracker_custom_tasks
      where id::text = (storage.foldername(name))[1]
    )
  );
create policy "tempest_editor_file_delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'fitm-evidence'
    and exists (select 1 from public.tracker_editors where user_id = (select auth.uid()))
  );

-- Optional: turn on Realtime replication for all tracker tables
do $$
declare tbl text;
begin
  foreach tbl in array array[
    'tracker_custom_projects','tracker_custom_weeks',
    'tracker_custom_tasks','tracker_custom_evidence'
  ] loop
    if not exists(
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public' and tablename = tbl
    ) then
      execute format('alter publication supabase_realtime add table public.%I', tbl);
    end if;
  end loop;
end $$;

commit;
