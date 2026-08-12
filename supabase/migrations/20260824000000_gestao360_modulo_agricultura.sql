-- =============================================================
-- MÓDULO AGRICULTURA — Secretaria Municipal de Agricultura e Desenvolvimento Rural
-- Schema: gestao360 (mesmo padrão de Saúde/Educação/Indústria e Comércio/Esporte)
-- =============================================================

create table if not exists gestao360.agro_secretaria (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null default 'Secretaria Municipal de Agricultura e Desenvolvimento Rural',
  cnpj text, secretario text, secretario_adjunto text, endereco text, telefone text, whatsapp text, email text,
  horario_atendimento text, responsaveis_setores text, setores text, orcamento_anual numeric(14,2), meta_anual numeric(14,2),
  observacoes text, criado_em timestamptz not null default now(), atualizado_em timestamptz
);

create table if not exists gestao360.agro_produtores (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, cpf_cnpj text, contato text, endereco text, comunidade text,
  atividade_principal text, atividades_secundarias text, agricultura_familiar boolean default false,
  associacao text, cooperativa text, situacao text not null default 'ativo' check (situacao in ('ativo','inativo')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_propriedades (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produtor_id uuid references gestao360.agro_produtores(id), nome text not null, localizacao text, comunidade text,
  area_total numeric(10,2), area_produtiva numeric(10,2), area_preservacao numeric(10,2), atividade text,
  acesso text, estrada text, infraestrutura text, agua text, energia text,
  situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_producao (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produtor_id uuid references gestao360.agro_produtores(id), propriedade_id uuid references gestao360.agro_propriedades(id),
  cultura text not null, safra text, area_plantada numeric(10,2), periodo text,
  producao_estimada numeric(12,2), producao_realizada numeric(12,2), unidade text, produtividade numeric(10,2),
  perdas numeric(10,2), comercializacao text, preco_medio numeric(10,2), criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_pecuaria (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produtor_id uuid references gestao360.agro_produtores(id), propriedade_id uuid references gestao360.agro_propriedades(id),
  especie text not null, quantidade integer, finalidade text, producao text, periodo text,
  comercializacao text, situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_familiar (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produtor_id uuid references gestao360.agro_produtores(id), propriedade_id uuid references gestao360.agro_propriedades(id),
  producao text, produtos text, participacao_programas text, comercializacao text, feiras text,
  compras_publicas boolean default false, assistencia_tecnica boolean default false, criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_hortas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produtor_id uuid references gestao360.agro_produtores(id), propriedade_id uuid references gestao360.agro_propriedades(id),
  area numeric(10,2), culturas text, producao text, destino text, comercializacao text,
  situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_agroindustrias (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  empreendimento text not null, produtor_id uuid references gestao360.agro_produtores(id), cnpj text, atividade text,
  produto text, capacidade text, producao text, estrutura text, licencas text, comercializacao text,
  situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_cooperativas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, cnpj text, responsavel text, endereco text, contato text, produtores_associados integer,
  atividades text, produtos text, comercializacao text, programas text, situacao text default 'ativa',
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_associacoes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, cnpj text, responsavel text, comunidade text, associados integer, atividade text,
  producao text, projetos text, programas text, situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_feiras (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, edicao text, data date, local text, produtores_participantes integer, bancas integer,
  produtos text, publico integer, comercializacao_informada numeric(12,2), custos numeric(12,2), parceiros text,
  resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_eventos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  evento text not null, data date, local text, produtores_participantes integer, participantes integer,
  parceiros text, atividades text, custo numeric(12,2), resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_produtos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produto text not null, categoria text, produtor_id uuid references gestao360.agro_produtores(id),
  propriedade_id uuid references gestao360.agro_propriedades(id), quantidade numeric(12,2), unidade text,
  preco numeric(10,2), origem text, comercializacao text, situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_comercializacao (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produtor_id uuid references gestao360.agro_produtores(id), produto text, quantidade numeric(12,2), unidade text,
  comprador_programa text, data date, valor numeric(12,2), situacao text default 'concluida',
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_compras_publicas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produtor_id uuid references gestao360.agro_produtores(id), organizacao text, produto text, quantidade numeric(12,2),
  valor numeric(12,2), orgao_comprador text, programa text, contrato text, entrega date,
  situacao text default 'em_andamento' check (situacao in ('em_andamento','entregue','cancelado')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_assistencia_tecnica (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produtor_id uuid references gestao360.agro_produtores(id), propriedade_id uuid references gestao360.agro_propriedades(id),
  tecnico text, data date default current_date, tipo text check (tipo in ('assistencia','visita_tecnica')),
  motivo text, atividade text, diagnostico text, orientacao text, recomendacao text, encaminhamento text,
  retorno date, situacao text default 'concluida', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_projetos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, objetivo text, publico text, produtor_id uuid references gestao360.agro_produtores(id),
  comunidade text, responsavel text, periodo text, orcamento numeric(14,2), parceiros text, meta text, resultado text,
  situacao text default 'em_andamento' check (situacao in ('em_andamento','concluido','cancelado')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_programas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, objetivo text, publico text, responsavel text, periodo text, orcamento numeric(14,2),
  participantes integer default 0, meta text, resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_cursos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  curso text not null, tema text, instrutor text, parceiro text, data date, carga_horaria integer,
  vagas integer, inscritos integer default 0, participantes integer default 0, frequencia numeric(5,1),
  conclusao integer default 0, certificado boolean default false, custo numeric(10,2), criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_insumos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produto text not null, categoria text check (categoria in ('sementes','mudas','fertilizantes','corretivos','materiais','outro')),
  fornecedor text, lote text, validade date, quantidade numeric(12,2), entrada numeric(12,2), saida numeric(12,2),
  saldo numeric(12,2), destino text, produtor_id uuid references gestao360.agro_produtores(id), custo numeric(10,2),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_sementes_mudas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  especie text not null, variedade text, lote text, origem text, validade date, quantidade numeric(12,2),
  produtor_id uuid references gestao360.agro_produtores(id), data date default current_date,
  situacao text default 'distribuida', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_maquinas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  maquina text not null, patrimonio text, marca text, modelo text, ano integer, capacidade text,
  combustivel text, horimetro numeric(10,1), operador text,
  situacao text default 'ativo' check (situacao in ('ativo','manutencao','inativo')), criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_implementos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  implemento text not null, tipo text, maquina_id uuid references gestao360.agro_maquinas(id), patrimonio text,
  localizacao text, situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_servicos_maquinas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produtor_id uuid references gestao360.agro_produtores(id), propriedade_id uuid references gestao360.agro_propriedades(id),
  servico text not null, maquina_id uuid references gestao360.agro_maquinas(id), operador text, data date,
  local text, horas_trabalhadas numeric(6,1), combustivel_litros numeric(8,1), custo numeric(10,2),
  situacao text default 'solicitado' check (situacao in ('solicitado','agendado','realizado','cancelado')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_operadores (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, matricula text, funcao text, habilitacao text, maquina_autorizada text, horario text,
  situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_estradas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  estrada text not null, trecho text, comunidade text, extensao_km numeric(8,2),
  prioridade text default 'media' check (prioridade in ('alta','media','baixa')),
  condicao text default 'regular' check (condicao in ('boa','regular','critica')),
  ultima_manutencao date, proxima_manutencao date, responsavel text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_manutencao_estradas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  estrada_id uuid references gestao360.agro_estradas(id), problema text, prioridade text default 'media',
  maquina_id uuid references gestao360.agro_maquinas(id), equipe text, data date, servico text, material text,
  custo numeric(12,2), conclusao date, situacao text default 'aberta' check (situacao in ('aberta','em_andamento','concluida','pendente')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_pontes_bueiros (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  localizacao text not null, estrada_id uuid references gestao360.agro_estradas(id), tipo text, dimensoes text,
  condicao text default 'regular' check (condicao in ('boa','regular','critica')), risco text,
  data_ultima_inspecao date, necessidade_intervencao boolean default false, custo_estimado numeric(12,2),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_recursos_hidricos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text check (tipo in ('nascente','poco','reservatorio','sistema_agua_rural','rio','corrego')),
  comunidade text, propriedade_id uuid references gestao360.agro_propriedades(id), localizacao text,
  capacidade text, situacao text default 'ativo', manutencao text, projeto text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_sanidade_animal (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  acao text not null, produtor_id uuid references gestao360.agro_produtores(id),
  propriedade_id uuid references gestao360.agro_propriedades(id), especie text, quantidade integer, data date,
  responsavel text, resultado text, encaminhamento text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_sustentavel (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  projeto text not null, tipo text, produtor_id uuid references gestao360.agro_produtores(id),
  propriedade_id uuid references gestao360.agro_propriedades(id), area_beneficiada numeric(10,2), acoes text,
  situacao text default 'em_andamento', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_credito_rural (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produtor_id uuid references gestao360.agro_produtores(id), finalidade text, instituicao text,
  valor_solicitado numeric(12,2), valor_aprovado numeric(12,2), projeto text, data date,
  situacao text default 'orientado' check (situacao in ('orientado','em_analise','aprovado','negado')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_convenios (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  parceiro text not null, objeto text, valor numeric(14,2), data_inicio date, data_fim date, contrapartida text,
  responsavel text, situacao text default 'vigente' check (situacao in ('vigente','encerrado','vencido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_incentivos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  produtor_id uuid references gestao360.agro_produtores(id), programa text, beneficio text, valor numeric(10,2),
  finalidade text, contrapartida text, resultado text, situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_financeiro (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text check (tipo in ('receita','despesa','empenho','liquidacao','pagamento')), descricao text,
  valor numeric(14,2), programa text, servico text, fonte_recurso text, fornecedor text, contrato text, data date,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_compras (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  solicitacao text, processo text, item text not null, quantidade integer, cotacao numeric(10,2), fornecedor text,
  valor numeric(12,2), data date default current_date, entrega date, nota_fiscal text,
  situacao text default 'solicitada' check (situacao in ('solicitada','em_cotacao','empenhada','entregue','cancelada')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_contratos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  numero text, processo text, fornecedor text not null, cnpj text, objeto text, valor numeric(14,2),
  data_inicio date, data_fim date, fiscal text, saldo numeric(14,2),
  situacao text default 'vigente' check (situacao in ('vigente','encerrado','aditado','rescindido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_metas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  indicador text not null, periodo text, meta_anual numeric(12,2), meta_mensal numeric(12,2), responsavel text,
  prazo date, resultado numeric(12,2), percentual numeric(5,1) default 0,
  situacao text default 'em_andamento' check (situacao in ('atingida','atencao','abaixo','em_andamento')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_indicadores (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, descricao text, formula text, fonte text, periodicidade text default 'mensal',
  meta numeric(12,2), resultado numeric(12,2), unidade_medida text, responsavel text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_alertas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text, mensagem text not null, severidade text default 'atencao' check (severidade in ('info','atencao','critico')),
  lido boolean default false, referencia_id uuid, criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_documentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  titulo text not null, tipo text, descricao text, modulo text, url text, data date default current_date,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.agro_auditoria (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  usuario text, data timestamptz default now(), acao text not null, modulo text, registro_id uuid,
  valor_anterior text, valor_novo text
);

-- ====================== RLS (isolado à secretaria "Agricultura" + Admin Master/Prefeito/Chefe de Gabinete) ======================
do $$
declare t text; sec_id uuid;
begin
  select id into sec_id from gestao360.secretarias where nome = 'Agricultura' order by criado_em asc limit 1;
  for t in select unnest(array[
    'agro_secretaria','agro_produtores','agro_propriedades','agro_producao','agro_pecuaria','agro_familiar',
    'agro_hortas','agro_agroindustrias','agro_cooperativas','agro_associacoes','agro_feiras','agro_eventos',
    'agro_produtos','agro_comercializacao','agro_compras_publicas','agro_assistencia_tecnica','agro_projetos',
    'agro_programas','agro_cursos','agro_insumos','agro_sementes_mudas','agro_maquinas','agro_implementos',
    'agro_servicos_maquinas','agro_operadores','agro_estradas','agro_manutencao_estradas','agro_pontes_bueiros',
    'agro_recursos_hidricos','agro_sanidade_animal','agro_sustentavel','agro_credito_rural','agro_convenios',
    'agro_incentivos','agro_financeiro','agro_compras','agro_contratos','agro_metas','agro_indicadores',
    'agro_alertas','agro_documentos','agro_auditoria'
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
