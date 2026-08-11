-- indicadores tinha select/insert mas nenhuma policy de update/delete, então a tela de
-- gestão nunca conseguiria editar/corrigir um valor já cadastrado.
drop policy if exists indicadores_update_staff on gestao360.indicadores;
create policy indicadores_update_staff on gestao360.indicadores for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id());
drop policy if exists indicadores_delete_staff on gestao360.indicadores;
create policy indicadores_delete_staff on gestao360.indicadores for delete to authenticated
  using (tenant_id = gestao360.jwt_tenant_id());

grant delete on gestao360.indicadores to authenticated;

notify pgrst, 'reload schema';
