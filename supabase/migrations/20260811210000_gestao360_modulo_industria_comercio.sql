-- =============================================================
-- MÓDULO INDÚSTRIA E COMÉRCIO — Secretaria Municipal
-- Schema: gestao360
-- =============================================================

-- 1. Secretaria
create table if not exists gestao360.ic_secretaria (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null default 'Secretaria Municipal de Indústria e Comércio',
  secretario text, responsaveis text, endereco text, telefone text, whatsapp text, email text,
  horario_atendimento text, setores text, servidores text,
  orcamento_anual numeric(14,2), meta_anual numeric(14,2),
  programas text, projetos text, observacoes text,
  criado_em timestamptz not null default now(), atualizado_em timestamptz
);

-- 2. Empresas
create table if not exists gestao360.ic_empresas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  razao_social text not null, nome_fantasia text, cnpj text, endereco text, bairro text,
  telefone text, whatsapp text, email text, responsavel text,
  cnae text, atividade_principal text, atividades_secundarias text,
  porte text check (porte in ('mei','me','epp','medio','grande')),
  natureza_juridica text,
  situacao text not null default 'ativa' check (situacao in ('ativa','inativa','suspensa','encerrada','em_implantacao')),
  data_abertura date, data_encerramento date, numero_funcionarios integer default 0,
  faturamento numeric(14,2), setor_economico text, origem text, observacoes text,
  criado_em timestamptz not null default now()
);

-- 3. MEIs
create table if not exists gestao360.ic_meis (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, cnpj text, atividade text, cnae text, endereco text, bairro text,
  telefone text, whatsapp text, email text, data_abertura date,
  situacao text not null default 'ativo' check (situacao in ('ativo','inativo','encerrado','suspenso')),
  setor text, atendimento_realizado text, capacitacoes_realizadas text,
  credito text, participacao_eventos text, necessidades text,
  criado_em timestamptz not null default now()
);

-- 4. Comércio
create table if not exists gestao360.ic_comercios (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empresa_id uuid references gestao360.ic_empresas(id),
  segmento text, atividade text, endereco text, bairro text, responsavel text,
  telefone text, whatsapp text, horario text, numero_funcionarios integer default 0,
  situacao text default 'ativo', participacao_campanhas text, participacao_eventos text,
  conecta_comercio boolean default false,
  criado_em timestamptz not null default now()
);

-- 5. Indústrias
create table if not exists gestao360.ic_industrias (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empresa_id uuid references gestao360.ic_empresas(id),
  cnpj text, atividade text, cnae text, endereco text, area text,
  numero_funcionarios integer default 0, capacidade text, producao text,
  situacao text default 'ativa', necessidades text,
  interesse_expansao boolean default false, interesse_incentivos boolean default false,
  area_necessaria text, investimentos_previstos numeric(14,2),
  criado_em timestamptz not null default now()
);

-- 6. Prestadores de Serviços
create table if not exists gestao360.ic_prestadores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empresa_id uuid references gestao360.ic_empresas(id),
  cnpj text, atividade text, cnae text, endereco text, bairro text, responsavel text,
  telefone text, numero_funcionarios integer default 0,
  situacao text default 'ativo',
  criado_em timestamptz not null default now()
);

-- 7. Empregos
create table if not exists gestao360.ic_empregos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empresa_id uuid references gestao360.ic_empresas(id),
  setor text, quantidade_funcionarios integer default 0,
  vagas_abertas integer default 0, vagas_preenchidas integer default 0,
  desligamentos integer default 0, admissoes integer default 0,
  periodo text, tipo_vaga text, faixa_salarial text,
  criado_em timestamptz not null default now()
);

-- 8. Trabalhadores
create table if not exists gestao360.ic_trabalhadores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  identificacao text not null, area_interesse text, profissao text,
  qualificacao text, experiencia text, disponibilidade text,
  situacao_emprego text default 'desempregado' check (situacao_emprego in ('empregado','desempregado','autonomo','informal')),
  interesse_vagas boolean default true, encaminhamentos text,
  criado_em timestamptz not null default now()
);

-- 9. Vagas de Emprego
create table if not exists gestao360.ic_vagas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empresa_id uuid references gestao360.ic_empresas(id),
  cargo text not null, quantidade integer default 1, requisitos text,
  escolaridade text, experiencia text, salario numeric(10,2),
  data_abertura date default current_date, prazo date,
  candidatos integer default 0, encaminhados integer default 0, contratados integer default 0,
  situacao text default 'aberta' check (situacao in ('aberta','preenchida','cancelada','expirada')),
  criado_em timestamptz not null default now()
);

-- 10. Atendimentos (Sala do Empreendedor)
create table if not exists gestao360.ic_atendimentos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  data date not null default current_date, empreendedor text,
  tipo_atendimento text, servico text check (servico in ('abertura_empresa','mei','alteracao','baixa','declaracao','regularizacao','orientacao','emissao_documentos','capacitacao','credito','compras_publicas','formalizacao','outro')),
  servidor_responsavel text, resultado text, encaminhamento text,
  retorno_necessario boolean default false,
  criado_em timestamptz not null default now()
);

-- 11. Fomento Paraná
create table if not exists gestao360.ic_fomento (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empreendedor text not null, identificacao text, atividade text,
  tipo_credito text, valor_solicitado numeric(12,2), valor_aprovado numeric(12,2),
  valor_contratado numeric(12,2), finalidade text,
  situacao text default 'proposta' check (situacao in ('proposta','analise','aprovada','contratada','negada','cancelada')),
  data date default current_date, acompanhamento text,
  criado_em timestamptz not null default now()
);

-- 12. Microcrédito
create table if not exists gestao360.ic_microcredito (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  interessado text not null, simulacao boolean default false,
  proposta boolean default false, aprovacao boolean default false,
  contratacao boolean default false, valor numeric(12,2), finalidade text,
  situacao text default 'interessado' check (situacao in ('interessado','simulacao','proposta','aprovado','contratado','negado','cancelado')),
  criado_em timestamptz not null default now()
);

-- 13. Capacitações
create table if not exists gestao360.ic_capacitacoes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  curso text not null, tema text, parceiro text, instrutor text,
  data date, horario text, local text,
  vagas integer default 0, inscricoes integer default 0, presenca integer default 0,
  conclusao integer default 0, certificado boolean default false,
  custo numeric(10,2), publico text,
  criado_em timestamptz not null default now()
);

-- 14. Cursos
create table if not exists gestao360.ic_cursos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, categoria text, instituicao text, carga_horaria integer,
  vagas integer default 0, periodo text, publico text, custo numeric(10,2), resultado text,
  criado_em timestamptz not null default now()
);

-- 15. Eventos
create table if not exists gestao360.ic_eventos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, tipo text, data date, local text, organizacao text, parceiros text,
  publico_alvo text, quantidade_participantes integer default 0,
  empresas_participantes integer default 0, empreendedores integer default 0,
  custos numeric(10,2), receitas numeric(10,2), resultado text,
  criado_em timestamptz not null default now()
);

-- 16. Feiras
create table if not exists gestao360.ic_feiras (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, data date, local text, edicao text,
  expositores integer default 0, empreendedores integer default 0,
  produtos text, vendas_informadas numeric(12,2), publico integer default 0,
  custos numeric(10,2), parceiros text, resultado text,
  criado_em timestamptz not null default now()
);

-- 17. Empreendedores
create table if not exists gestao360.ic_empreendedores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, empresa text, atividade text, segmento text,
  formalizacao text, participacao_cursos text, participacao_eventos text,
  participacao_feiras text, credito text, programas text,
  criado_em timestamptz not null default now()
);

-- 18. Artesãos
create table if not exists gestao360.ic_artesaos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, atividade text, produto text, contato text, endereco text,
  formalizacao text, participacao_feiras text, capacitacoes text, eventos text,
  criado_em timestamptz not null default now()
);

-- 19. Produtores
create table if not exists gestao360.ic_produtores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, atividade text, produto text, localizacao text, contato text,
  participacao_feiras text, programas text, eventos text,
  criado_em timestamptz not null default now()
);

-- 20. Turismo e Economia Local
create table if not exists gestao360.ic_turismo (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empreendimento text not null, tipo text check (tipo in ('atrativo','restaurante','hospedagem','produtor','artesao','evento','atividade','outro')),
  cadastur text, localizacao text, contato text,
  situacao text default 'ativo',
  criado_em timestamptz not null default now()
);

-- 21. Compras Públicas
create table if not exists gestao360.ic_compras_publicas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  processo text, objeto text, categoria text, fornecedor text,
  empresa_local text, valor numeric(12,2), participacao text, resultado text,
  situacao text default 'aberta',
  criado_em timestamptz not null default now()
);

-- 22. Licitações e Oportunidades
create table if not exists gestao360.ic_licitacoes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  processo text, orgao text, objeto text not null, prazo date,
  valor_estimado numeric(14,2), categoria text, publico_interessado text,
  situacao text default 'aberta' check (situacao in ('aberta','encerrada','cancelada','suspensa')),
  criado_em timestamptz not null default now()
);

-- 23. Programas e Projetos
create table if not exists gestao360.ic_programas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, tipo text default 'programa' check (tipo in ('programa','projeto')),
  objetivo text, publico text, responsavel text, periodo text,
  orcamento numeric(12,2), parceiros text, metas text, resultados text,
  criado_em timestamptz not null default now()
);

-- 24. Alvarás e Licenças
create table if not exists gestao360.ic_alvaras (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empresa_id uuid references gestao360.ic_empresas(id),
  tipo text, protocolo text, data date, vencimento date,
  situacao text default 'vigente' check (situacao in ('vigente','vencido','cancelado','em_analise','pendente')),
  responsavel text, documento text, pendencias text,
  criado_em timestamptz not null default now()
);

-- 25. Fiscalizações
create table if not exists gestao360.ic_fiscalizacoes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empresa_id uuid references gestao360.ic_empresas(id),
  data date not null default current_date, motivo text, tipo text,
  situacao text default 'realizada' check (situacao in ('agendada','realizada','pendente','concluida')),
  orientacao text, prazo date, regularizacao text, resultado text,
  criado_em timestamptz not null default now()
);

-- 26. Investimentos
create table if not exists gestao360.ic_investimentos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empresa text, projeto text not null, segmento text,
  valor_estimado numeric(14,2), empregos_previstos integer default 0,
  area_necessaria text, cronograma text, responsavel text,
  etapa text default 'interesse' check (etapa in ('interesse','analise','negociacao','aprovacao','implantacao','operacao')),
  situacao text default 'em_andamento',
  criado_em timestamptz not null default now()
);

-- 27. Áreas e Terrenos
create table if not exists gestao360.ic_areas_terrenos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  area text not null, localizacao text, tamanho text, infraestrutura text,
  disponibilidade text default 'disponivel' check (disponibilidade in ('disponivel','reservado','ocupado','indisponivel')),
  finalidade text, proprietario text, documentacao text,
  criado_em timestamptz not null default now()
);

-- 28. Empresas Interessadas
create table if not exists gestao360.ic_empresas_interessadas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empresa text not null, segmento text, contato text, telefone text, email text,
  area_interesse text, empregos_previstos integer default 0,
  investimento_previsto numeric(14,2), necessidades text,
  situacao text default 'prospectando' check (situacao in ('prospectando','em_negociacao','aprovada','desistiu')),
  area_terreno_id uuid references gestao360.ic_areas_terrenos(id),
  criado_em timestamptz not null default now()
);

-- 29. Incentivos e Benefícios
create table if not exists gestao360.ic_incentivos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  empresa_id uuid references gestao360.ic_empresas(id),
  programa text, beneficio text, valor numeric(12,2), tipo text, prazo text,
  contrapartida text, empregos_previstos integer default 0,
  empregos_realizados integer default 0,
  situacao text default 'vigente' check (situacao in ('vigente','encerrado','cancelado','em_analise')),
  criado_em timestamptz not null default now()
);

-- 30. Financeiro
create table if not exists gestao360.ic_financeiro (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  tipo text not null check (tipo in ('receita','despesa','empenho','liquidacao','pagamento')),
  descricao text, valor numeric(14,2), programa text, projeto text,
  fonte_recurso text, fornecedor text, contrato text, data date default current_date,
  criado_em timestamptz not null default now()
);

-- 31. Contratos
create table if not exists gestao360.ic_contratos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  numero text, processo text, fornecedor text not null, cnpj text,
  objeto text, valor numeric(14,2), data_inicio date, data_fim date,
  fiscal text, saldo numeric(14,2),
  situacao text default 'vigente' check (situacao in ('vigente','encerrado','aditado','rescindido')),
  criado_em timestamptz not null default now()
);

-- 32. Metas
create table if not exists gestao360.ic_metas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  indicador text not null, meta_anual numeric(12,2), meta_mensal numeric(12,2),
  meta_trimestral numeric(12,2), responsavel text, prazo date,
  resultado numeric(12,2), percentual numeric(5,2),
  situacao text default 'atencao' check (situacao in ('atingida','atencao','abaixo')),
  periodo text,
  criado_em timestamptz not null default now()
);

-- 33. Indicadores
create table if not exists gestao360.ic_indicadores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, descricao text, formula text, fonte text,
  periodicidade text default 'mensal', meta numeric(12,2),
  unidade_medida text, responsavel text,
  criado_em timestamptz not null default now()
);

-- 34. Alertas config
create table if not exists gestao360.ic_alertas_config (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, descricao text, condicao text,
  severidade text default 'atencao' check (severidade in ('info','atencao','critico')),
  ativo boolean default true,
  criado_em timestamptz not null default now()
);

-- 35. Alertas
create table if not exists gestao360.ic_alertas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  mensagem text not null, severidade text default 'atencao',
  modulo text, lido boolean default false,
  criado_em timestamptz not null default now()
);

-- 36. Documentos
create table if not exists gestao360.ic_documentos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  titulo text not null, tipo text, descricao text, modulo text,
  url text, data date default current_date,
  criado_em timestamptz not null default now()
);

-- 37. Auditoria
create table if not exists gestao360.ic_auditoria (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  usuario text, data timestamptz default now(), acao text not null,
  modulo text, registro_id uuid, valor_anterior text, valor_novo text
);

-- ============ RLS ============
do $$
declare t text;
begin
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
    execute format('alter table gestao360.%I enable row level security', t);
    execute format('drop policy if exists tenant_iso on gestao360.%I', t);
    execute format(
      'create policy tenant_iso on gestao360.%I for all using (tenant_id = gestao360.jwt_tenant_id()) with check (tenant_id = gestao360.jwt_tenant_id())', t
    );
    execute format('grant select, insert, update, delete on gestao360.%I to authenticated', t);
  end loop;
end$$;
