-- Atrações da festa (bandas, DJs, shows, apresentações culturais, competições etc.)
create table if not exists gestao360.evento_atracoes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  nome text not null,
  tipo text,
  data date,
  horario time,
  descricao text,
  responsavel text,
  valor numeric(12,2),
  forma_contratacao text,
  forma_pagamento text,
  situacao text not null default 'a_contratar',
  observacoes text,
  criado_em timestamptz not null default now()
);

alter table gestao360.evento_atracoes enable row level security;

drop policy if exists evento_atracoes_select_staff on gestao360.evento_atracoes;
create policy evento_atracoes_select_staff on gestao360.evento_atracoes for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_atracoes_insert_staff on gestao360.evento_atracoes;
create policy evento_atracoes_insert_staff on gestao360.evento_atracoes for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_atracoes_update_staff on gestao360.evento_atracoes;
create policy evento_atracoes_update_staff on gestao360.evento_atracoes for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));
drop policy if exists evento_atracoes_delete_staff on gestao360.evento_atracoes;
create policy evento_atracoes_delete_staff on gestao360.evento_atracoes for delete to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));

grant select, insert, update, delete on gestao360.evento_atracoes to authenticated;

notify pgrst, 'reload schema';
