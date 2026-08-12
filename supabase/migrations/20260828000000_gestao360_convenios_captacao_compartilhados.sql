-- Convênios (dos 5 módulos novos) e Captação de Recursos deixam de ser isolados por secretaria —
-- viram visíveis/editáveis por qualquer secretaria (mesmo tenant). Prefeito, Vice-Prefeito, Chefe de
-- Gabinete e Admin Master continuam vendo tudo, agora consistente com o resto (já viam tudo antes).
-- Plano de Governo: Vice-Prefeito passa a poder cadastrar/editar também (antes só admin_master/prefeito/chefe).

-- Captação de Recursos: volta a ser compartilhada entre todas as secretarias
drop policy if exists recursos_select_staff on gestao360.oportunidades_recursos;
create policy recursos_select_staff on gestao360.oportunidades_recursos for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id());

drop policy if exists recursos_insert_staff on gestao360.oportunidades_recursos;
create policy recursos_insert_staff on gestao360.oportunidades_recursos for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id());

drop policy if exists recursos_update_staff on gestao360.oportunidades_recursos;
create policy recursos_update_staff on gestao360.oportunidades_recursos for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id());

-- Convênios dos módulos novos: tira o isolamento por secretaria, mantém só o isolamento por tenant
do $$
declare t text;
begin
  for t in select unnest(array['esporte_convenios','agro_convenios','cult_convenios','as_convenios','ma_convenios'])
  loop
    execute format('drop policy if exists tenant_iso on gestao360.%I', t);
    execute format(
      'create policy tenant_iso on gestao360.%I for all using (tenant_id = gestao360.jwt_tenant_id()) with check (tenant_id = gestao360.jwt_tenant_id())',
      t
    );
  end loop;
end$$;

-- Plano de Governo: Vice-Prefeito também cadastra/edita
drop policy if exists promessas_insert_gestao on gestao360.promessas_campanha;
create policy promessas_insert_gestao on gestao360.promessas_campanha for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_perfil() = 'vice_prefeito'));

drop policy if exists promessas_update_gestao on gestao360.promessas_campanha;
create policy promessas_update_gestao on gestao360.promessas_campanha for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_perfil() = 'vice_prefeito'));

notify pgrst, 'reload schema';
