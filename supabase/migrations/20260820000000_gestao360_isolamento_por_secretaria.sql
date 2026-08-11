-- Documentos (acao_anexos) e Captação de Recursos deixavam qualquer secretário ver/editar
-- dados de OUTRAS secretarias (só checavam tenant_id, não secretaria_id). Corrige pra
-- só Admin Master + o secretário dono daquela pasta terem acesso.

-- acao_anexos: usa o mesmo padrão dos itens do dossiê da festa (join com acoes.secretaria_id)
drop policy if exists acao_anexos_select_staff on gestao360.acao_anexos;
create policy acao_anexos_select_staff on gestao360.acao_anexos for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));

drop policy if exists acao_anexos_insert_staff on gestao360.acao_anexos;
create policy acao_anexos_insert_staff on gestao360.acao_anexos for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));

drop policy if exists acao_anexos_update_staff on gestao360.acao_anexos;
create policy acao_anexos_update_staff on gestao360.acao_anexos for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));

drop policy if exists acao_anexos_delete_staff on gestao360.acao_anexos;
create policy acao_anexos_delete_staff on gestao360.acao_anexos for delete to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id())));

-- oportunidades_recursos: secretaria_id nulo = "toda a prefeitura" (todo mundo vê), senão só a secretaria dona
drop policy if exists recursos_select_staff on gestao360.oportunidades_recursos;
create policy recursos_select_staff on gestao360.oportunidades_recursos for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_ampla() or secretaria_id is null or secretaria_id = gestao360.jwt_secretaria_id()));

drop policy if exists recursos_insert_staff on gestao360.oportunidades_recursos;
create policy recursos_insert_staff on gestao360.oportunidades_recursos for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_ampla() or secretaria_id is null or secretaria_id = gestao360.jwt_secretaria_id()));

drop policy if exists recursos_update_staff on gestao360.oportunidades_recursos;
create policy recursos_update_staff on gestao360.oportunidades_recursos for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_ampla() or secretaria_id is null or secretaria_id = gestao360.jwt_secretaria_id()));

notify pgrst, 'reload schema';
