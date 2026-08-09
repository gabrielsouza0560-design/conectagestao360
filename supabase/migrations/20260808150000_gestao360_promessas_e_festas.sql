-- Plano de Governo: secretaria, mídia, edição e metas
alter table gestao360.promessas_campanha
  add column if not exists secretaria_id uuid references gestao360.secretarias(id),
  add column if not exists foto_url text,
  add column if not exists video_url text,
  add column if not exists atualizado_em timestamptz;

create table if not exists gestao360.promessa_metas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  promessa_id uuid not null references gestao360.promessas_campanha(id) on delete cascade,
  titulo text not null,
  concluida boolean not null default false,
  criado_em timestamptz not null default now()
);

alter table gestao360.promessa_metas enable row level security;

drop policy if exists promessa_metas_select_public on gestao360.promessa_metas;
create policy promessa_metas_select_public on gestao360.promessa_metas for select to anon, authenticated using (true);
drop policy if exists promessa_metas_insert_gestao on gestao360.promessa_metas;
create policy promessa_metas_insert_gestao on gestao360.promessa_metas for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and gestao360.jwt_perfil() in ('admin_master','prefeito'));
drop policy if exists promessa_metas_update_gestao on gestao360.promessa_metas;
create policy promessa_metas_update_gestao on gestao360.promessa_metas for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and gestao360.jwt_perfil() in ('admin_master','prefeito'));
drop policy if exists promessa_metas_delete_gestao on gestao360.promessa_metas;
create policy promessa_metas_delete_gestao on gestao360.promessa_metas for delete to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and gestao360.jwt_perfil() in ('admin_master','prefeito'));

grant select on gestao360.promessa_metas to anon, authenticated;
grant insert, update, delete on gestao360.promessa_metas to authenticated;

-- Festas: quantos comerciantes/barraqueiros participaram
alter table gestao360.acoes add column if not exists comerciantes_participantes integer;
