-- =============================================================
-- MÓDULO CULTURA — Secretaria Municipal de Cultura (inclui Cine Tuba)
-- Schema: gestao360 (mesmo padrão de Saúde/Educação/Indústria e Comércio/Esporte/Agricultura)
-- =============================================================

create table if not exists gestao360.cult_secretaria (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null default 'Secretaria Municipal de Cultura', cnpj text, secretario text, secretario_adjunto text,
  endereco text, telefone text, whatsapp text, email text, horario_atendimento text, responsaveis_setores text,
  setores text, orcamento_anual numeric(14,2), meta_anual numeric(14,2), observacoes text,
  criado_em timestamptz not null default now(), atualizado_em timestamptz
);

create table if not exists gestao360.cult_artistas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, nome_artistico text,
  modalidade text check (modalidade in ('musica','danca','teatro','artes_visuais','literatura','artesanato','fotografia','audiovisual','cinema','cultura_popular','outra')),
  contato text, endereco text, redes_sociais text, portfolio text, biografia text,
  situacao text not null default 'ativo' check (situacao in ('ativo','inativo')), criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_agentes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, tipo text check (tipo in ('agente_cultural','produtor_cultural')), area text, contato text,
  cpf_cnpj text, projetos text, editais text, eventos text, recursos_recebidos numeric(12,2),
  situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_grupos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, categoria text, responsavel text, integrantes integer, modalidade text,
  local_atuacao text, contato text, situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_associacoes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, cnpj text, responsavel text, endereco text, finalidade text, atividades text,
  situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_espacos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  tipo text check (tipo in ('casa_cultura','biblioteca','museu','sala_exposicoes','teatro','centro_cultural','cine_tuba','outro')),
  endereco text, responsavel text, capacidade integer, estrutura text, equipamentos text, acessibilidade boolean default false,
  horarios text, situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_biblioteca (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  titulo text not null, autor text, categoria text, isbn text, quantidade integer default 1, localizacao text,
  emprestimo date, devolucao date, usuario text,
  situacao text default 'disponivel' check (situacao in ('disponivel','emprestado','indisponivel')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_acervo (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  item text not null, categoria text, descricao text, origem text, data date, localizacao text, responsavel text,
  estado text default 'bom', criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_patrimonio (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, tipo text check (tipo in ('cultural','historico')), localizacao text, descricao text,
  importancia text, situacao text default 'preservado', tombamento boolean default false,
  necessidade_conservacao boolean default false, historico text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_producoes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  linguagem text check (linguagem in ('musica','danca','teatro','artes_visuais','artesanato','literatura','audiovisual')),
  artista_grupo text, participantes integer, apresentacoes integer default 0, resultado text,
  situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_oficinas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, tipo text check (tipo in ('oficina','curso')), area text, instrutor text, local text,
  data_inicio date, data_fim date, carga_horaria integer, vagas integer, inscritos integer default 0,
  participantes integer default 0, frequencia numeric(5,1), conclusao integer default 0, custo numeric(10,2),
  resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_projetos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, objetivo text, area text, publico text, responsavel text, periodo text,
  orcamento numeric(14,2), parceiros text, meta text, participantes integer, resultado text,
  situacao text default 'em_andamento' check (situacao in ('em_andamento','concluido','cancelado')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_programas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, objetivo text, publico text, responsavel text, periodo text, orcamento numeric(14,2),
  acoes text, resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_eventos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, tipo text check (tipo in ('evento','festival','feira_cultural')), data date, horario text,
  local text, organizador text, artistas text, grupos text, publico integer, parceiros text, patrocinadores text,
  custo numeric(12,2), resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_exposicoes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, artista text, obras text, local text, data_inicio date, data_fim date,
  visitantes integer, custo numeric(10,2), resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_apresentacoes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  artista_grupo text not null, modalidade text, evento text, data date, local text, publico integer,
  valor numeric(10,2), contrato text, situacao text default 'confirmada', criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_editais (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, area text, publicacao date, inscricao_inicio date, inscricao_fim date, vagas integer,
  valor numeric(12,2), criterios text, candidatos integer default 0, selecionados integer default 0,
  situacao text default 'aberto' check (situacao in ('aberto','em_analise','resultado_publicado','encerrado')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_fomento (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  beneficiario text not null, projeto text, edital_id uuid references gestao360.cult_editais(id), valor numeric(12,2),
  situacao text default 'em_execucao' check (situacao in ('em_execucao','concluido','prestacao_contas','cancelado')),
  resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_incentivos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  artista_grupo text not null, projeto text, valor numeric(10,2), contrapartida text, periodo text,
  resultado text, situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_convenios (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  parceiro text not null, objeto text, valor numeric(14,2), data_inicio date, data_fim date, contrapartida text,
  responsavel text, situacao text default 'vigente' check (situacao in ('vigente','encerrado','vencido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_recursos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  origem text not null, programa text, valor numeric(14,2), finalidade text, executado numeric(14,2) default 0,
  saldo numeric(14,2), situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_equipamentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  equipamento text not null, patrimonio text, localizacao text, responsavel text, valor numeric(10,2),
  data_aquisicao date, situacao text default 'funcionando' check (situacao in ('funcionando','manutencao','inativo')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_reservas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  espaco_id uuid references gestao360.cult_espacos(id), solicitante text not null, data date not null,
  horario_inicio time, horario_fim time, finalidade text, publico_estimado integer, responsavel text,
  situacao text not null default 'solicitada' check (situacao in ('solicitada','aprovada','recusada','realizada','cancelada')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_inscricoes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  atividade text, oficina_id uuid references gestao360.cult_oficinas(id), evento_id uuid references gestao360.cult_eventos(id),
  participante text not null, data date default current_date, presenca boolean default false, conclusao boolean default false,
  situacao text default 'inscrito', criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_financeiro (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text check (tipo in ('receita','despesa','empenho','liquidacao','pagamento')), descricao text,
  valor numeric(14,2), programa text, projeto text, evento text, area_cultural text, fonte_recurso text,
  fornecedor text, contrato text, data date, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_compras (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  solicitacao text, processo text, item text not null, quantidade integer, cotacao numeric(10,2), fornecedor text,
  valor numeric(12,2), data date default current_date, entrega date, nota_fiscal text,
  situacao text default 'solicitada' check (situacao in ('solicitada','em_cotacao','empenhada','entregue','cancelada')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_contratos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  numero text, processo text, fornecedor text not null, cnpj text, objeto text, valor numeric(14,2),
  data_inicio date, data_fim date, fiscal text, saldo numeric(14,2),
  situacao text default 'vigente' check (situacao in ('vigente','encerrado','aditado','rescindido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_metas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  indicador text not null, periodo text, meta_anual numeric(12,2), meta_mensal numeric(12,2), responsavel text,
  prazo date, resultado numeric(12,2), percentual numeric(5,1) default 0,
  situacao text default 'em_andamento' check (situacao in ('atingida','atencao','abaixo','em_andamento')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_indicadores (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, descricao text, formula text, fonte text, periodicidade text default 'mensal',
  meta numeric(12,2), resultado numeric(12,2), unidade_medida text, responsavel text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_documentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  titulo text not null, tipo text, descricao text, modulo text, url text, data date default current_date,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_alertas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text, mensagem text not null, severidade text default 'atencao' check (severidade in ('info','atencao','critico')),
  lido boolean default false, referencia_id uuid, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cult_auditoria (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  usuario text, data timestamptz default now(), acao text not null, modulo text, registro_id uuid,
  valor_anterior text, valor_novo text
);

-- ====================== CINE TUBA (módulo dedicado dentro de Cultura) ======================

create table if not exists gestao360.cine_config (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null default 'Cine Tuba', endereco text, responsavel text, capacidade_sala integer,
  numero_assentos integer, acessibilidade boolean default false, projetor text, sistema_som text, tela text,
  iluminacao text, climatizacao boolean default false, internet boolean default false,
  horario_funcionamento text, dias_funcionamento text, situacao text default 'ativo',
  criado_em timestamptz not null default now(), atualizado_em timestamptz
);

create table if not exists gestao360.cine_filmes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  titulo text not null, genero text, classificacao_indicativa text, duracao_min integer, diretor text,
  pais text, ano integer, distribuidora text, formato text, idioma text, legenda boolean default false,
  situacao text default 'disponivel', criado_em timestamptz not null default now()
);

create table if not exists gestao360.cine_sessoes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  filme_id uuid references gestao360.cine_filmes(id), data date not null, horario time, capacidade integer,
  ingressos_vagas integer, publico integer, tipo_sessao text check (tipo_sessao in ('regular','educativa','especial','gratuita')),
  acessibilidade boolean default false, escola_grupo text,
  situacao text default 'programada' check (situacao in ('programada','realizada','cancelada','lotada')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cine_escolas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  sessao_id uuid references gestao360.cine_sessoes(id), escola text not null, turma text,
  quantidade_alunos integer, professores integer, responsavel text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cine_eventos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  evento text not null, tipo text check (tipo in ('mostra','festival','sessao_especial','cinema_educativo','cinema_infantil','cinema_comunitario','documentario','debate','palestra')),
  filme_id uuid references gestao360.cine_filmes(id), data date, publico integer, custo numeric(10,2),
  parceiros text, resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cine_financeiro (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text check (tipo in ('licenca_filme','manutencao','energia','equipamento','divulgacao','pessoal','evento','outro')),
  descricao text, valor numeric(10,2), data date, criado_em timestamptz not null default now()
);

create table if not exists gestao360.cine_equipamentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  equipamento text not null, numero_serie text, data_aquisicao date, valor numeric(10,2), localizacao text,
  situacao text default 'funcionando' check (situacao in ('funcionando','manutencao','indisponivel')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.cine_manutencao (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  equipamento_id uuid references gestao360.cine_equipamentos(id), problema text not null,
  prioridade text default 'media' check (prioridade in ('alta','media','baixa')), data date default current_date,
  responsavel text, orcamento numeric(10,2), custo numeric(10,2), conclusao date,
  situacao text default 'aberta' check (situacao in ('aberta','em_andamento','resolvido','pendente')),
  criado_em timestamptz not null default now()
);

-- ====================== RLS (isolado à secretaria "Cultura" + Admin Master/Prefeito/Chefe de Gabinete) ======================
do $$
declare t text; sec_id uuid;
begin
  select id into sec_id from gestao360.secretarias where nome = 'Cultura' order by criado_em asc limit 1;
  for t in select unnest(array[
    'cult_secretaria','cult_artistas','cult_agentes','cult_grupos','cult_associacoes','cult_espacos',
    'cult_biblioteca','cult_acervo','cult_patrimonio','cult_producoes','cult_oficinas','cult_projetos',
    'cult_programas','cult_eventos','cult_exposicoes','cult_apresentacoes','cult_editais','cult_fomento',
    'cult_incentivos','cult_convenios','cult_recursos','cult_equipamentos','cult_reservas','cult_inscricoes',
    'cult_financeiro','cult_compras','cult_contratos','cult_metas','cult_indicadores','cult_documentos',
    'cult_alertas','cult_auditoria',
    'cine_config','cine_filmes','cine_sessoes','cine_escolas','cine_eventos','cine_financeiro',
    'cine_equipamentos','cine_manutencao'
  ])
  loop
    execute format('alter table gestao360.%I enable row level security', t);
    execute format('drop policy if exists tenant_iso on gestao360.%I', t);
    execute format(
      'create policy tenant_iso on gestao360.%I for all using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L)) with check (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L))',
      t, sec_id, sec_id
    );
    execute format('grant select, insert, update, delete on gestao360.%I to authenticated', t);
  end loop;
end$$;

grant usage on schema gestao360 to authenticated;

notify pgrst, 'reload schema';
