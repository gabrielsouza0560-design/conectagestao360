-- Central de IA passa a gravar de verdade: cada conteúdo gerado + a fila de aprovação
-- viram registros reais em gestao360.ia_conteudos (antes era tudo mockado no JS, sumia ao recarregar).

create table if not exists gestao360.ia_conteudos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  tipo text not null,
  acao_id uuid references gestao360.acoes(id),
  tom text,
  instrucoes text,
  conteudo text not null,
  status text not null default 'pendente' check (status in ('pendente','aprovado','reprovado')),
  criado_por text,
  criado_em timestamptz not null default now()
);

alter table gestao360.ia_conteudos enable row level security;

drop policy if exists ia_conteudos_select on gestao360.ia_conteudos;
create policy ia_conteudos_select on gestao360.ia_conteudos for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id());

drop policy if exists ia_conteudos_insert on gestao360.ia_conteudos;
create policy ia_conteudos_insert on gestao360.ia_conteudos for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id());

drop policy if exists ia_conteudos_update on gestao360.ia_conteudos;
create policy ia_conteudos_update on gestao360.ia_conteudos for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id());

grant select, insert, update on gestao360.ia_conteudos to authenticated;

notify pgrst, 'reload schema';
