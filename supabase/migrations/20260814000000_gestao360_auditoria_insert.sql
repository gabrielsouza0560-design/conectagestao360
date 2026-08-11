-- logs_auditoria já existia (só tinha select p/ admin_master) mas faltava a policy de insert,
-- então nada nunca conseguia gravar log nenhum.
drop policy if exists logs_insert_staff on gestao360.logs_auditoria;
create policy logs_insert_staff on gestao360.logs_auditoria for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id());

notify pgrst, 'reload schema';
