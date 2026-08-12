-- =============================================================
-- MÓDULO ASSISTÊNCIA SOCIAL — Secretaria Municipal de Assistência Social (inclui CRAS/CREAS)
-- Schema: gestao360 (mesmo padrão de Saúde/Educação/Indústria e Comércio/Esporte/Agricultura/Cultura)
-- Trabalha com dados pessoais e dados sensíveis: RLS restringe SEMPRE a
-- Admin Master/Prefeito/Chefe de Gabinete + staff da própria secretaria — sem exceção,
-- e nenhuma dessas tabelas é exposta a "anon" (cidadão) em nenhuma tela pública.
-- =============================================================

create table if not exists gestao360.as_secretaria (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null default 'Secretaria Municipal de Assistência Social', cnpj text, secretario text, secretario_adjunto text,
  endereco text, telefone text, whatsapp text, email text, horario_atendimento text, responsaveis_setores text,
  setores text, orcamento_anual numeric(14,2), meta_anual numeric(14,2), observacoes text,
  criado_em timestamptz not null default now(), atualizado_em timestamptz
);

create table if not exists gestao360.as_cras (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, endereco text, bairro text, telefone text, email text, coordenador text, equipe text,
  horario text, territorio_abrangencia text, capacidade integer, servicos_oferecidos text,
  situacao_estrutura text default 'boa' check (situacao_estrutura in ('boa','regular','precaria')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_creas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, endereco text, equipe text, servicos text, rede_protecao text,
  situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_unidades (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  tipo text check (tipo in ('cras','creas','centro_convivencia','abrigo','casa_acolhimento','outro')),
  endereco text, responsavel text, equipe text, capacidade integer, servicos text, horarios text,
  situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_familias (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  identificador text, responsavel_familiar text not null, quantidade_membros integer, endereco text,
  bairro text, telefone text, composicao_familiar text, situacao_socioeconomica text,
  em_acompanhamento boolean default false, situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_pessoas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, data_nascimento date, sexo text check (sexo in ('M','F')),
  familia_id uuid references gestao360.as_familias(id), vinculo_familiar text, endereco text, contato text,
  situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_cadastro_social (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  familia_id uuid references gestao360.as_familias(id), renda numeric(10,2), situacao_habitacional text,
  trabalho text, escolaridade text, acesso_servicos text, vulnerabilidades text, necessidades text,
  em_acompanhamento boolean default false, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_cadastro_unico (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  familia_id uuid references gestao360.as_familias(id), numero_nis text,
  situacao text default 'atualizado' check (situacao in ('atualizado','desatualizado','pendente')),
  data_ultima_atualizacao date, beneficios_vinculados text, pendencias text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_beneficios (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  familia_id uuid references gestao360.as_familias(id), pessoa_id uuid references gestao360.as_pessoas(id),
  tipo text check (tipo in ('transferencia_renda','eventual','auxilio_natalidade','auxilio_funeral','cesta','auxilio_alimentacao','auxilio_documentacao','outro')),
  beneficio text not null, valor_quantidade numeric(10,2), motivo text, programa text, data date default current_date,
  situacao text default 'concedido' check (situacao in ('solicitado','em_analise','concedido','negado')),
  responsavel text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_programas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, objetivo text, publico text, responsavel text, unidade_id uuid references gestao360.as_unidades(id),
  periodo text, meta integer, orcamento numeric(14,2), participantes integer default 0, resultado text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_servicos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, unidade_id uuid references gestao360.as_unidades(id), publico text, equipe text,
  capacidade integer, horario text, quantidade_atendida integer default 0, meta integer, resultado text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_atendimentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  familia_id uuid references gestao360.as_familias(id), pessoa_id uuid references gestao360.as_pessoas(id),
  data date not null default current_date, unidade_id uuid references gestao360.as_unidades(id), profissional text,
  motivo text, servico text, orientacao text, encaminhamento text, retorno date,
  situacao text default 'concluido', criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_acompanhamentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  familia_id uuid references gestao360.as_familias(id), pessoa_id uuid references gestao360.as_pessoas(id),
  profissional text, unidade_id uuid references gestao360.as_unidades(id), data_inicio date default current_date,
  motivo text, objetivo text, plano_acompanhamento text, acoes text, encaminhamentos text,
  situacao text default 'ativo' check (situacao in ('ativo','encerrado')), data_encerramento date,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_visitas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  familia_id uuid references gestao360.as_familias(id), endereco text, profissional text, data date default current_date,
  motivo text, situacao_encontrada text, orientacao text, encaminhamento text, retorno_necessario boolean default false,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_encaminhamentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  familia_id uuid references gestao360.as_familias(id), pessoa_id uuid references gestao360.as_pessoas(id),
  origem text, destino text not null, motivo text, data date default current_date, responsavel text, prazo date,
  situacao text default 'pendente' check (situacao in ('pendente','concluido')), retorno text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_busca_ativa (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  territorio text, familia_id uuid references gestao360.as_familias(id), motivo text, data date default current_date,
  responsavel text, situacao text default 'identificada' check (situacao in ('identificada','localizada','encaminhada')),
  resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_grupos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, servico_id uuid references gestao360.as_servicos(id), unidade_id uuid references gestao360.as_unidades(id),
  profissional text, publico text, data date, horario text, participantes integer default 0,
  frequencia numeric(5,1), atividades text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_oficinas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, tema text, instrutor text, local text, periodo text, vagas integer,
  inscritos integer default 0, participantes integer default 0, frequencia numeric(5,1), resultado text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_publico_especifico (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  pessoa_id uuid references gestao360.as_pessoas(id),
  publico text check (publico in ('crianca_adolescente','idoso','pessoa_com_deficiencia','mulher','gestante')),
  servico text, participacao text, beneficio text, encaminhamento text, acompanhamento text,
  data date default current_date, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_seguranca_alimentar (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  familia_id uuid references gestao360.as_familias(id), tipo text check (tipo in ('cesta','refeicao','beneficio')),
  composicao text, quantidade integer default 1, data date default current_date, fornecedor text,
  custo numeric(10,2), programa text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_documentacao_pessoal (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  pessoa_id uuid references gestao360.as_pessoas(id), documento text not null, data date default current_date,
  situacao text default 'solicitado' check (situacao in ('solicitado','encaminhado','concluido')),
  encaminhamento text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_trabalho_renda (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  pessoa_id uuid references gestao360.as_pessoas(id), qualificacao text, profissao text, interesse text,
  encaminhamento text, curso text, vaga text, resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_cursos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  curso text not null, parceiro text, instrutor text, data date, carga_horaria integer, vagas integer,
  inscritos integer default 0, frequencia numeric(5,1), conclusao integer default 0, certificado boolean default false,
  custo numeric(10,2), criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_habitacao (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  familia_id uuid references gestao360.as_familias(id), demanda text not null, situacao text default 'em_analise',
  encaminhamento text, programa text, documentacao text, resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_violencias (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text not null, data date default current_date, unidade_id uuid references gestao360.as_unidades(id),
  encaminhamento text, rede_atendimento text, situacao text default 'em_acompanhamento' check (situacao in ('em_acompanhamento','encerrado')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_rede_atendimento (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  instituicao text not null, tipo text, responsavel text, contato text, endereco text, servico text,
  tipo_encaminhamento text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_conselho_tutelar (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  data date default current_date, origem text, destino text, motivo text,
  situacao text default 'encaminhado' check (situacao in ('encaminhado','em_andamento','retorno_recebido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_convenios (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  parceiro text not null, objeto text, valor numeric(14,2), data_inicio date, data_fim date, contrapartida text,
  responsavel text, situacao text default 'vigente' check (situacao in ('vigente','encerrado','vencido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_recursos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  origem text not null, programa text, valor numeric(14,2), finalidade text, executado numeric(14,2) default 0,
  saldo numeric(14,2), situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_estoque (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  item text not null, categoria text check (categoria in ('alimento','material','roupa','cobertor','kit','higiene','outro')),
  quantidade integer default 0, estoque_minimo integer default 0, validade date, localizacao text,
  fornecedor text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_financeiro (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text check (tipo in ('receita','despesa','empenho','liquidacao','pagamento')), descricao text,
  valor numeric(14,2), programa text, servico text, beneficio text, fonte_recurso text, fornecedor text,
  contrato text, data date, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_compras (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  solicitacao text, processo text, item text not null, quantidade integer, cotacao numeric(10,2), fornecedor text,
  valor numeric(12,2), data date default current_date, entrega date, nota_fiscal text,
  situacao text default 'solicitada' check (situacao in ('solicitada','em_cotacao','empenhada','entregue','cancelada')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_contratos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  numero text, processo text, fornecedor text not null, cnpj text, objeto text, valor numeric(14,2),
  data_inicio date, data_fim date, fiscal text, saldo numeric(14,2),
  situacao text default 'vigente' check (situacao in ('vigente','encerrado','aditado','rescindido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_metas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  indicador text not null, periodo text, meta_anual numeric(12,2), meta_mensal numeric(12,2), responsavel text,
  prazo date, resultado numeric(12,2), percentual numeric(5,1) default 0,
  situacao text default 'em_andamento' check (situacao in ('atingida','atencao','abaixo','em_andamento')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_indicadores (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, descricao text, formula text, fonte text, periodicidade text default 'mensal',
  meta numeric(12,2), resultado numeric(12,2), unidade_medida text, responsavel text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_documentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  titulo text not null, tipo text, descricao text, modulo text, url text, data date default current_date,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_alertas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text, mensagem text not null, severidade text default 'atencao' check (severidade in ('info','atencao','critico')),
  lido boolean default false, referencia_id uuid, criado_em timestamptz not null default now()
);

create table if not exists gestao360.as_auditoria (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  usuario text, data timestamptz default now(), acao text not null, modulo text, registro_id uuid,
  valor_anterior text, valor_novo text
);

-- ====================== RLS (isolado à secretaria "Assistência Social" + Admin Master/Prefeito/Chefe de Gabinete) ======================
-- Sem policy nenhuma pra "anon" em nenhuma tabela deste módulo — dado sensível nunca é público.
do $$
declare t text; sec_id uuid;
begin
  select id into sec_id from gestao360.secretarias where nome ilike '%assist%ncia social%' order by criado_em asc limit 1;
  for t in select unnest(array[
    'as_secretaria','as_cras','as_creas','as_unidades','as_familias','as_pessoas','as_cadastro_social',
    'as_cadastro_unico','as_beneficios','as_programas','as_servicos','as_atendimentos','as_acompanhamentos',
    'as_visitas','as_encaminhamentos','as_busca_ativa','as_grupos','as_oficinas','as_publico_especifico',
    'as_seguranca_alimentar','as_documentacao_pessoal','as_trabalho_renda','as_cursos','as_habitacao',
    'as_violencias','as_rede_atendimento','as_conselho_tutelar','as_convenios','as_recursos','as_estoque',
    'as_financeiro','as_compras','as_contratos','as_metas','as_indicadores','as_documentos',
    'as_alertas','as_auditoria'
  ])
  loop
    execute format('alter table gestao360.%I enable row level security', t);
    execute format('drop policy if exists tenant_iso on gestao360.%I', t);
    execute format(
      'create policy tenant_iso on gestao360.%I for all to authenticated using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L)) with check (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L))',
      t, sec_id, sec_id
    );
    execute format('grant select, insert, update, delete on gestao360.%I to authenticated', t);
  end loop;
end$$;

grant usage on schema gestao360 to authenticated;

notify pgrst, 'reload schema';
