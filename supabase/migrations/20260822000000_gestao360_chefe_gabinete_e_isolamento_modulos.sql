-- 1) Chefe de Gabinete passa a existir como perfil e ter os mesmos poderes do Admin Master
--    (Prefeito já tinha a maior parte, agora fica 100% igual também).
-- 2) Os módulos de secretaria (Saúde / Indústria e Comércio / Educação) deixam de ser
--    visíveis/acessíveis para QUALQUER funcionário do tenant e passam a valer só para:
--    Admin Master, Prefeito, Chefe de Gabinete, ou quem é da própria secretaria.

insert into gestao360.perfis (nome, descricao)
values ('chefe_de_gabinete', 'Chefe de Gabinete — acesso total, nível Admin Master')
on conflict (nome) do nothing;

-- "gestão total": mesmo nível de acesso do Admin Master
create or replace function gestao360.eh_gestao_total() returns boolean
  language sql stable as $$
    select gestao360.jwt_perfil() in ('admin_master','prefeito','chefe_de_gabinete')
  $$;

-- eh_gestao_ampla() (usada em Documentos, Captação de Recursos, dossiê de festa etc.) também libera pro Chefe de Gabinete
create or replace function gestao360.eh_gestao_ampla() returns boolean
  language sql stable as $$
    select gestao360.jwt_perfil() in ('admin_master','prefeito','chefe_de_gabinete','vice_prefeito','controladoria','comunicacao')
  $$;

-- usuários: gerenciar (ver/editar todo mundo) agora inclui Prefeito e Chefe de Gabinete
drop policy if exists usuarios_select_self on gestao360.usuarios;
create policy usuarios_select_self on gestao360.usuarios for select to authenticated
  using (auth_user_id = auth.uid() or (gestao360.eh_gestao_total() and tenant_id = gestao360.jwt_tenant_id()));
drop policy if exists usuarios_update_admin on gestao360.usuarios;
create policy usuarios_update_admin on gestao360.usuarios for update to authenticated
  using (gestao360.eh_gestao_total() and tenant_id = gestao360.jwt_tenant_id());

-- auditoria: leitura agora inclui Prefeito e Chefe de Gabinete
drop policy if exists logs_select_admin on gestao360.logs_auditoria;
create policy logs_select_admin on gestao360.logs_auditoria for select to authenticated
  using (gestao360.eh_gestao_total() and tenant_id = gestao360.jwt_tenant_id());

-- secretarias: cadastrar/editar agora inclui Prefeito e Chefe de Gabinete
drop policy if exists secretarias_insert_admin on gestao360.secretarias;
create policy secretarias_insert_admin on gestao360.secretarias for insert to authenticated
  with check (gestao360.eh_gestao_total() and tenant_id = gestao360.jwt_tenant_id());

-- avaliações/manifestações/plano de governo: mesma regra, agora com Chefe de Gabinete
drop policy if exists avaliacoes_select_gestao on gestao360.avaliacoes;
create policy avaliacoes_select_gestao on gestao360.avaliacoes for select to authenticated
  using (gestao360.eh_gestao_total());
drop policy if exists manifestacoes_select_gestao on gestao360.manifestacoes;
create policy manifestacoes_select_gestao on gestao360.manifestacoes for select to authenticated
  using (gestao360.eh_gestao_total());
drop policy if exists promessas_insert_gestao on gestao360.promessas_campanha;
create policy promessas_insert_gestao on gestao360.promessas_campanha for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and gestao360.eh_gestao_total());
drop policy if exists promessas_update_gestao on gestao360.promessas_campanha;
create policy promessas_update_gestao on gestao360.promessas_campanha for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and gestao360.eh_gestao_total());

-- RPCs de gestão de usuário: liberar pra Prefeito e Chefe de Gabinete também
create or replace function gestao360.aprovar_usuario(p_usuario_id uuid)
returns void
language plpgsql security definer set search_path = gestao360, public
as $$
begin
  if not exists (
    select 1 from gestao360.usuarios u join gestao360.perfis p on p.id = u.perfil_id
    where u.auth_user_id = auth.uid() and p.nome in ('admin_master','prefeito','chefe_de_gabinete')
  ) then
    raise exception 'Apenas Admin Master, Prefeito ou Chefe de Gabinete podem aprovar usuários';
  end if;
  update gestao360.usuarios set status = 'ativo' where id = p_usuario_id;
end;
$$;

create or replace function gestao360.admin_criar_usuario(p_auth_user_id uuid, p_nome text, p_perfil_nome text, p_secretaria_id uuid)
returns void
language plpgsql security definer set search_path = gestao360, public
as $$
declare
  v_perfil_id uuid;
  v_tenant_id uuid;
begin
  if not exists (
    select 1 from gestao360.usuarios u join gestao360.perfis p on p.id = u.perfil_id
    where u.auth_user_id = auth.uid() and p.nome in ('admin_master','prefeito','chefe_de_gabinete')
  ) then
    raise exception 'Apenas Admin Master, Prefeito ou Chefe de Gabinete podem cadastrar usuários diretamente';
  end if;

  select id into v_tenant_id from gestao360.tenants order by criado_em asc limit 1;
  select id into v_perfil_id from gestao360.perfis where nome = p_perfil_nome;
  if v_perfil_id is null then raise exception 'Cargo inválido'; end if;

  insert into gestao360.usuarios (auth_user_id, tenant_id, nome, email, perfil_id, secretaria_id, status)
  values (p_auth_user_id, v_tenant_id, p_nome, (select email from auth.users where id = p_auth_user_id), v_perfil_id, p_secretaria_id, 'ativo');
end;
$$;

-- ============================================================
-- Isolamento por secretaria dos módulos dedicados (Saúde, Indústria e Comércio, Educação):
-- antes só checavam tenant_id (qualquer funcionário via qualquer secretaria via), agora só
-- Admin Master / Prefeito / Chefe de Gabinete OU quem é da própria secretaria.
-- ============================================================

do $$
declare t text; sec_id uuid;
begin
  select id into sec_id from gestao360.secretarias where nome = 'Saúde' order by criado_em asc limit 1;
  for t in select unnest(array[
    'saude_secretaria','saude_unidades','saude_equipes','saude_profissionais',
    'saude_pacientes','saude_consultas','saude_atendimentos','saude_exames',
    'saude_odontologia','saude_vacinas','saude_vacinacao','saude_vacina_estoque',
    'saude_medicamentos','saude_farmacia_mov','saude_visitas','saude_encaminhamentos',
    'saude_regulacao','saude_frota','saude_transporte','saude_frota_abastecimentos',
    'saude_frota_manutencoes','saude_estoque','saude_estoque_mov','saude_compras',
    'saude_contratos','saude_programas','saude_campanhas','saude_metas',
    'saude_indicadores_config','saude_alertas_config','saude_alertas'
  ])
  loop
    execute format('drop policy if exists %I on gestao360.%I', 'tenant_iso_'||t, t);
    execute format(
      'create policy %I on gestao360.%I for all using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L)) with check (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L))',
      'tenant_iso_'||t, t, sec_id, sec_id
    );
  end loop;
end$$;

do $$
declare t text; sec_id uuid;
begin
  select id into sec_id from gestao360.secretarias where nome = 'Educação' order by criado_em asc limit 1;
  for t in select unnest(array[
    'ed_secretaria','ed_escolas','ed_alunos','ed_matriculas','ed_vagas',
    'ed_turmas','ed_professores','ed_servidores','ed_frequencia','ed_avaliacoes',
    'ed_aprendizagem','ed_educacao_infantil','ed_educacao_especial','ed_transporte',
    'ed_frota','ed_frota_abastecimentos','ed_frota_manutencoes','ed_alimentacao',
    'ed_estoque','ed_biblioteca','ed_tecnologia','ed_infraestrutura','ed_manutencao',
    'ed_programas','ed_projetos','ed_eventos','ed_familia','ed_ocorrencias',
    'ed_compras','ed_contratos','ed_financeiro','ed_metas','ed_indicadores',
    'ed_alertas_config','ed_alertas','ed_documentos','ed_auditoria'
  ])
  loop
    execute format('drop policy if exists %I on gestao360.%I', t||'_tenant', t);
    execute format(
      'create policy %I on gestao360.%I for all to authenticated using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L)) with check (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L))',
      t||'_tenant', t, sec_id, sec_id
    );
  end loop;
end$$;

do $$
declare t text; sec_id uuid;
begin
  select id into sec_id from gestao360.secretarias where nome = 'Indústria e Comércio' order by criado_em asc limit 1;
  for t in select unnest(array[
    'ic_secretaria','ic_empresas','ic_meis','ic_comercios','ic_industrias','ic_prestadores',
    'ic_empregos','ic_trabalhadores','ic_vagas','ic_atendimentos','ic_fomento','ic_microcredito',
    'ic_capacitacoes','ic_cursos','ic_eventos','ic_feiras','ic_empreendedores','ic_artesaos',
    'ic_produtores','ic_turismo','ic_compras_publicas','ic_licitacoes','ic_programas',
    'ic_alvaras','ic_fiscalizacoes','ic_investimentos','ic_areas_terrenos','ic_empresas_interessadas',
    'ic_incentivos','ic_financeiro','ic_contratos','ic_metas','ic_indicadores',
    'ic_alertas_config','ic_alertas','ic_documentos','ic_auditoria'
  ])
  loop
    execute format('drop policy if exists tenant_iso on gestao360.%I', t);
    execute format(
      'create policy tenant_iso on gestao360.%I for all using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L)) with check (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L))',
      t, sec_id, sec_id
    );
  end loop;
end$$;

notify pgrst, 'reload schema';
