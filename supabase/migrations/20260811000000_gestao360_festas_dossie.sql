-- Dossiê completo de Festas/Eventos: dados gerais, comerciantes/barracas,
-- patrocínios, crianças do desfile + arrecadação de alimentos, checklist.

alter table gestao360.acoes
  add column if not exists tipo_evento text,
  add column if not exists local text,
  add column if not exists data_fim date,
  add column if not exists hora_inicio time,
  add column if not exists hora_fim time,
  add column if not exists endereco text,
  add column if not exists finalidade text,
  add column if not exists objetivos text,
  add column if not exists publico_alvo text;

create table if not exists gestao360.evento_comerciantes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  nome text not null,
  cpf_cnpj text,
  empresa text,
  telefone text,
  whatsapp text,
  segmento text,
  produto text,
  tipo_participacao text,
  numero_barraca text,
  localizacao text,
  tamanho text,
  valor_cobrado numeric(10,2),
  isento boolean not null default false,
  forma_pagamento text,
  situacao text not null default 'confirmado',
  observacoes text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.evento_patrocinios (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  nome text not null,
  cnpj_cpf text,
  responsavel text,
  telefone text,
  tipo_apoio text,
  valor numeric(12,2),
  forma_pagamento text,
  descricao_apoio text,
  contrapartida text,
  observacoes text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.evento_desfile_criancas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  categoria text not null check (categoria in ('apae','cidade')),
  nome text not null,
  escola_responsavel text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.evento_arrecadacao_alimentos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  participante text not null,
  alimento text,
  quantidade_kg numeric(10,2) not null default 0,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.evento_checklist (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  item text not null,
  concluido boolean not null default false,
  criado_em timestamptz not null default now()
);

alter table gestao360.evento_comerciantes enable row level security;
alter table gestao360.evento_patrocinios enable row level security;
alter table gestao360.evento_desfile_criancas enable row level security;
alter table gestao360.evento_arrecadacao_alimentos enable row level security;
alter table gestao360.evento_checklist enable row level security;

-- evento_comerciantes
drop policy if exists evento_comerciantes_select_staff on gestao360.evento_comerciantes;
create policy evento_comerciantes_select_staff on gestao360.evento_comerciantes for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_comerciantes_insert_staff on gestao360.evento_comerciantes;
create policy evento_comerciantes_insert_staff on gestao360.evento_comerciantes for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_comerciantes_update_staff on gestao360.evento_comerciantes;
create policy evento_comerciantes_update_staff on gestao360.evento_comerciantes for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_comerciantes_delete_staff on gestao360.evento_comerciantes;
create policy evento_comerciantes_delete_staff on gestao360.evento_comerciantes for delete to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));

-- evento_patrocinios
drop policy if exists evento_patrocinios_select_staff on gestao360.evento_patrocinios;
create policy evento_patrocinios_select_staff on gestao360.evento_patrocinios for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_patrocinios_insert_staff on gestao360.evento_patrocinios;
create policy evento_patrocinios_insert_staff on gestao360.evento_patrocinios for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_patrocinios_update_staff on gestao360.evento_patrocinios;
create policy evento_patrocinios_update_staff on gestao360.evento_patrocinios for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_patrocinios_delete_staff on gestao360.evento_patrocinios;
create policy evento_patrocinios_delete_staff on gestao360.evento_patrocinios for delete to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));

-- evento_desfile_criancas
drop policy if exists evento_desfile_criancas_select_staff on gestao360.evento_desfile_criancas;
create policy evento_desfile_criancas_select_staff on gestao360.evento_desfile_criancas for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_desfile_criancas_insert_staff on gestao360.evento_desfile_criancas;
create policy evento_desfile_criancas_insert_staff on gestao360.evento_desfile_criancas for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_desfile_criancas_update_staff on gestao360.evento_desfile_criancas;
create policy evento_desfile_criancas_update_staff on gestao360.evento_desfile_criancas for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_desfile_criancas_delete_staff on gestao360.evento_desfile_criancas;
create policy evento_desfile_criancas_delete_staff on gestao360.evento_desfile_criancas for delete to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));

-- evento_arrecadacao_alimentos
drop policy if exists evento_arrecadacao_select_staff on gestao360.evento_arrecadacao_alimentos;
create policy evento_arrecadacao_select_staff on gestao360.evento_arrecadacao_alimentos for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_arrecadacao_insert_staff on gestao360.evento_arrecadacao_alimentos;
create policy evento_arrecadacao_insert_staff on gestao360.evento_arrecadacao_alimentos for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_arrecadacao_update_staff on gestao360.evento_arrecadacao_alimentos;
create policy evento_arrecadacao_update_staff on gestao360.evento_arrecadacao_alimentos for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_arrecadacao_delete_staff on gestao360.evento_arrecadacao_alimentos;
create policy evento_arrecadacao_delete_staff on gestao360.evento_arrecadacao_alimentos for delete to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));

-- evento_checklist
drop policy if exists evento_checklist_select_staff on gestao360.evento_checklist;
create policy evento_checklist_select_staff on gestao360.evento_checklist for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_checklist_insert_staff on gestao360.evento_checklist;
create policy evento_checklist_insert_staff on gestao360.evento_checklist for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_checklist_update_staff on gestao360.evento_checklist;
create policy evento_checklist_update_staff on gestao360.evento_checklist for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_checklist_delete_staff on gestao360.evento_checklist;
create policy evento_checklist_delete_staff on gestao360.evento_checklist for delete to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));

grant select, insert, update, delete on gestao360.evento_comerciantes to authenticated;
grant select, insert, update, delete on gestao360.evento_patrocinios to authenticated;
grant select, insert, update, delete on gestao360.evento_desfile_criancas to authenticated;
grant select, insert, update, delete on gestao360.evento_arrecadacao_alimentos to authenticated;
grant select, insert, update, delete on gestao360.evento_checklist to authenticated;

notify pgrst, 'reload schema';
