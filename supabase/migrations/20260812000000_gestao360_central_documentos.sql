-- Central de Documentos: reaproveita gestao360.acao_anexos (já existia, nunca foi usada na tela)
alter table gestao360.acao_anexos
  add column if not exists categoria text,
  add column if not exists storage_path text,
  add column if not exists enviado_por text;

drop policy if exists acao_anexos_delete_staff on gestao360.acao_anexos;
create policy acao_anexos_delete_staff on gestao360.acao_anexos for delete to authenticated
  using (tenant_id = gestao360.jwt_tenant_id());

grant delete on gestao360.acao_anexos to authenticated;

-- bucket privado — documentos oficiais (PM, Bombeiros, Conselho Tutelar, contratos etc.)
insert into storage.buckets (id, name, public) values ('documentos', 'documentos', false) on conflict (id) do nothing;

drop policy if exists documentos_storage_select on storage.objects;
create policy documentos_storage_select on storage.objects for select to authenticated
  using (bucket_id = 'documentos');
drop policy if exists documentos_storage_insert on storage.objects;
create policy documentos_storage_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'documentos');
drop policy if exists documentos_storage_delete on storage.objects;
create policy documentos_storage_delete on storage.objects for delete to authenticated
  using (bucket_id = 'documentos');

notify pgrst, 'reload schema';
