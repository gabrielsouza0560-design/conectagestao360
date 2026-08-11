-- Ações (inclui Festas e Obras, que reaproveitam essa tabela) nunca tiveram policy de exclusão.
drop policy if exists acoes_delete_staff on gestao360.acoes;
create policy acoes_delete_staff on gestao360.acoes for delete to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_ampla() or secretaria_id = gestao360.jwt_secretaria_id()));

grant delete on gestao360.acoes to authenticated;

notify pgrst, 'reload schema';
