-- Histórico de relatórios PDF gerados (fica salvo na plataforma, não só no download local)
create table if not exists gestao360.relatorios_gerados (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  titulo text not null,
  tipo text not null,
  formato text not null default 'pdf',
  storage_path text not null,
  gerado_por text,
  criado_em timestamptz not null default now()
);

alter table gestao360.relatorios_gerados enable row level security;

create policy relatorios_gerados_select_staff on gestao360.relatorios_gerados for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id());
create policy relatorios_gerados_insert_staff on gestao360.relatorios_gerados for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id());

grant select, insert on gestao360.relatorios_gerados to authenticated;

-- bucket privado — só quem está logado no sistema consegue baixar
insert into storage.buckets (id, name, public) values ('relatorios', 'relatorios', false) on conflict (id) do nothing;

create policy relatorios_storage_select on storage.objects for select to authenticated
  using (bucket_id = 'relatorios');
create policy relatorios_storage_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'relatorios');
