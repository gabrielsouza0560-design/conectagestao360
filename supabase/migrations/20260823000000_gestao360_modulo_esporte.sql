-- =============================================================
-- MÓDULO ESPORTE — Secretaria Municipal de Esporte
-- Schema: gestao360 (integrado ao sistema existente, mesmo padrão de Saúde/Educação/Indústria e Comércio)
-- =============================================================

create table if not exists gestao360.esporte_secretaria (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null default 'Secretaria Municipal de Esporte',
  cnpj text, secretario text, secretario_adjunto text, endereco text, telefone text, whatsapp text, email text,
  horario_atendimento text, responsaveis_setores text, setores text, orcamento_anual numeric(14,2), meta_anual numeric(14,2),
  observacoes text, criado_em timestamptz not null default now(), atualizado_em timestamptz
);

create table if not exists gestao360.esporte_modalidades (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, descricao text, faixa_etaria text, local text, dias text, horarios text,
  capacidade integer, situacao text not null default 'ativa' check (situacao in ('ativa','inativa')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_categorias (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, idade_minima integer, idade_maxima integer,
  modalidade_id uuid references gestao360.esporte_modalidades(id), sexo text, situacao text default 'ativa',
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_equipes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, modalidade_id uuid references gestao360.esporte_modalidades(id),
  categoria_id uuid references gestao360.esporte_categorias(id), tecnico text, comissao text,
  local_treinamento text, calendario text, vitorias integer default 0, derrotas integer default 0, empates integer default 0,
  titulos integer default 0, situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_profissionais (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, matricula text,
  funcao text check (funcao in ('professor','tecnico','monitor','arbitro','outro')),
  formacao text, especialidade text, modalidade_id uuid references gestao360.esporte_modalidades(id),
  categoria_id uuid references gestao360.esporte_categorias(id), carga_horaria integer, horario text,
  situacao text not null default 'ativo' check (situacao in ('ativo','afastado','inativo')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_atletas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  identificador text, nome text not null, data_nascimento date, sexo text check (sexo in ('M','F')),
  modalidade_id uuid references gestao360.esporte_modalidades(id), categoria_id uuid references gestao360.esporte_categorias(id),
  equipe_id uuid references gestao360.esporte_equipes(id), escola text, bairro text, contato text,
  responsavel_nome text, responsavel_contato text, nivel_esportivo text,
  situacao text not null default 'ativo' check (situacao in ('ativo','inativo')),
  data_cadastro date default current_date, criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_escolinhas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, modalidade_id uuid references gestao360.esporte_modalidades(id), local text,
  professor text, tecnico text, categoria_id uuid references gestao360.esporte_categorias(id), dias text, horarios text,
  capacidade integer, inscritos integer default 0, lista_espera integer default 0,
  situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_projetos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, objetivo text, publico text, modalidade_id uuid references gestao360.esporte_modalidades(id),
  responsavel text, local text, periodo text, orcamento numeric(14,2), parceiros text,
  meta integer, participantes integer default 0, resultado text,
  situacao text default 'em_andamento' check (situacao in ('em_andamento','concluido','cancelado')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_treinamentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  equipe_id uuid references gestao360.esporte_equipes(id), modalidade_id uuid references gestao360.esporte_modalidades(id),
  tecnico text, data date not null default current_date, horario text, local text, duracao_min integer,
  participantes integer, presenca integer, observacoes text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_competicoes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, tipo text check (tipo in ('competicao','campeonato')), edicao text,
  modalidade_id uuid references gestao360.esporte_modalidades(id), categoria_id uuid references gestao360.esporte_categorias(id),
  organizacao text, local text, periodo_inicio date, periodo_fim date, regulamento text, premiacao text,
  custo numeric(12,2), patrocinadores text,
  situacao text default 'planejada' check (situacao in ('planejada','em_andamento','concluida','cancelada')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_jogos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  competicao_id uuid references gestao360.esporte_competicoes(id), rodada text, data date, horario text, local text,
  equipe_mandante_id uuid references gestao360.esporte_equipes(id), equipe_visitante_id uuid references gestao360.esporte_equipes(id),
  placar_mandante integer, placar_visitante integer, arbitro text, publico integer,
  situacao text default 'agendado' check (situacao in ('agendado','realizado','cancelado','adiado')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_resultados (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  atleta_id uuid references gestao360.esporte_atletas(id), equipe_id uuid references gestao360.esporte_equipes(id),
  competicao_id uuid references gestao360.esporte_competicoes(id), modalidade_id uuid references gestao360.esporte_modalidades(id),
  colocacao text, medalha text check (medalha in ('ouro','prata','bronze','') ), pontuacao numeric(10,2), recorde boolean default false,
  titulo boolean default false, data date, observacoes text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_eventos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, tipo text, data date, local text, modalidade_id uuid references gestao360.esporte_modalidades(id),
  publico_estimado integer, participantes integer, parceiros text, patrocinadores text, custo numeric(12,2),
  estrutura text, resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_inscricoes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  evento_id uuid references gestao360.esporte_eventos(id), competicao_id uuid references gestao360.esporte_competicoes(id),
  atleta_id uuid references gestao360.esporte_atletas(id), equipe_id uuid references gestao360.esporte_equipes(id),
  modalidade_id uuid references gestao360.esporte_modalidades(id), categoria_id uuid references gestao360.esporte_categorias(id),
  data date default current_date,
  situacao text not null default 'inscrito' check (situacao in ('inscrito','confirmado','cancelado','eliminado','concluido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_arbitragem (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  arbitro text not null, jogo_id uuid references gestao360.esporte_jogos(id), competicao_id uuid references gestao360.esporte_competicoes(id),
  modalidade_id uuid references gestao360.esporte_modalidades(id), categoria_id uuid references gestao360.esporte_categorias(id),
  data date, valor numeric(10,2), situacao text default 'confirmado', criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_espacos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  tipo text check (tipo in ('ginasio','quadra','campo','estadio','pista','centro_esportivo','academia','comunitario','outro')),
  endereco text, responsavel text, capacidade integer, modalidades text, iluminacao boolean default false,
  vestiarios boolean default false, banheiros boolean default false, arquibancada boolean default false,
  acessibilidade boolean default false, estacionamento boolean default false,
  estado_conservacao text default 'bom' check (estado_conservacao in ('bom','regular','ruim')),
  equipamentos text, horario_funcionamento text, situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_reservas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  espaco_id uuid references gestao360.esporte_espacos(id), solicitante text not null, data date not null,
  horario_inicio time, horario_fim time, finalidade text, modalidade_id uuid references gestao360.esporte_modalidades(id),
  quantidade_participantes integer, responsavel text,
  situacao text not null default 'solicitada' check (situacao in ('solicitada','aprovada','recusada','realizada','cancelada')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_manutencao (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  espaco_id uuid references gestao360.esporte_espacos(id), problema text not null,
  prioridade text default 'media' check (prioridade in ('alta','media','baixa')),
  data date default current_date, responsavel text, orcamento numeric(12,2), custo numeric(12,2), conclusao date,
  situacao text default 'aberta' check (situacao in ('aberta','em_andamento','resolvido','pendente')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_materiais (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  item text not null, categoria text, quantidade integer default 0, patrimonio text, localizacao text,
  estado text default 'bom' check (estado in ('bom','regular','danificado')), responsavel text,
  data_aquisicao date, valor numeric(10,2), criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_uniformes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  modalidade_id uuid references gestao360.esporte_modalidades(id), equipe_id uuid references gestao360.esporte_equipes(id),
  atleta_id uuid references gestao360.esporte_atletas(id), tamanho text, quantidade integer default 1,
  fornecedor text, valor numeric(10,2), data_entrega date,
  situacao text default 'entregue' check (situacao in ('disponivel','entregue','pendente')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_estoque (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  material text not null, categoria text, unidade_medida text default 'unidade',
  quantidade integer default 0, estoque_minimo integer default 0, estoque_maximo integer,
  localizacao text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_estoque_mov (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  estoque_id uuid references gestao360.esporte_estoque(id), tipo text check (tipo in ('entrada','saida','ajuste','perda')),
  quantidade integer not null, data date default current_date, destino text, observacoes text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_transporte (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  competicao_id uuid references gestao360.esporte_competicoes(id), evento_id uuid references gestao360.esporte_eventos(id),
  equipe_id uuid references gestao360.esporte_equipes(id), destino text, data date, horario text,
  veiculo text, motorista text, passageiros integer, quilometragem numeric(10,1), combustivel_litros numeric(8,1),
  custo numeric(10,2), criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_frota (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  veiculo text not null, placa text, modelo text, ano integer, capacidade integer,
  combustivel text default 'flex', quilometragem numeric(10,1) default 0, motorista text,
  seguro_vencimento date, licenciamento_vencimento date,
  situacao text default 'ativo' check (situacao in ('ativo','manutencao','inativo')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_frota_abastecimentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  veiculo_id uuid references gestao360.esporte_frota(id), data date default current_date, litros numeric(8,2),
  valor numeric(10,2), quilometragem numeric(10,1), posto text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_frota_manutencoes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  veiculo_id uuid references gestao360.esporte_frota(id), data date default current_date, tipo text, descricao text,
  valor numeric(10,2), oficina text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_avaliacoes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  atleta_id uuid references gestao360.esporte_atletas(id), modalidade_id uuid references gestao360.esporte_modalidades(id),
  data date default current_date, avaliacao text, resultado text, evolucao text, observacoes text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_bolsas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  atleta_id uuid references gestao360.esporte_atletas(id), programa text, modalidade_id uuid references gestao360.esporte_modalidades(id),
  beneficio text, valor numeric(10,2), periodo text, criterios text, resultado text,
  situacao text default 'ativa' check (situacao in ('ativa','encerrada','suspensa')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_convenios (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  parceiro text not null, objeto text, valor numeric(14,2), data_inicio date, data_fim date, contrapartida text,
  responsavel text, situacao text default 'vigente' check (situacao in ('vigente','encerrado','vencido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_patrocinios (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  empresa text not null, evento_id uuid references gestao360.esporte_eventos(id), equipe_id uuid references gestao360.esporte_equipes(id),
  modalidade_id uuid references gestao360.esporte_modalidades(id), valor numeric(12,2), tipo_apoio text,
  periodo text, contrapartida text, situacao text default 'ativo', criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_programas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, objetivo text, publico text, modalidade_id uuid references gestao360.esporte_modalidades(id),
  responsavel text, periodo text, orcamento numeric(14,2), meta integer, participantes integer default 0,
  resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_financeiro (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text check (tipo in ('receita','despesa','empenho','liquidacao','pagamento')), descricao text,
  valor numeric(14,2), programa text, projeto text, evento text, competicao text, fonte_recurso text,
  fornecedor text, contrato text, data date, criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_compras (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  solicitacao text, processo text, item text not null, quantidade integer, cotacao numeric(10,2),
  fornecedor text, valor numeric(12,2), data date default current_date, entrega date, nota_fiscal text,
  situacao text default 'solicitada' check (situacao in ('solicitada','em_cotacao','empenhada','entregue','cancelada')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_contratos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  numero text, processo text, fornecedor text not null, cnpj text, objeto text, valor numeric(14,2),
  data_inicio date, data_fim date, fiscal text, saldo numeric(14,2),
  situacao text default 'vigente' check (situacao in ('vigente','encerrado','aditado','rescindido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_metas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  indicador text not null, periodo text, meta_anual numeric(12,2), meta_mensal numeric(12,2),
  responsavel text, prazo date, resultado numeric(12,2), percentual numeric(5,1) default 0,
  situacao text default 'em_andamento' check (situacao in ('atingida','atencao','abaixo','em_andamento')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_indicadores (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, descricao text, formula text, fonte text, periodicidade text default 'mensal',
  meta numeric(12,2), resultado numeric(12,2), unidade_medida text, responsavel text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_alertas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text, mensagem text not null, severidade text default 'atencao' check (severidade in ('info','atencao','critico')),
  lido boolean default false, referencia_id uuid, criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_documentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  titulo text not null, tipo text, descricao text, modulo text, url text, data date default current_date,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.esporte_auditoria (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  usuario text, data timestamptz default now(), acao text not null, modulo text, registro_id uuid,
  valor_anterior text, valor_novo text
);

-- ====================== RLS (isolado à secretaria "Esporte" + Admin Master/Prefeito/Chefe de Gabinete) ======================
do $$
declare t text; sec_id uuid;
begin
  select id into sec_id from gestao360.secretarias where nome = 'Esporte' order by criado_em asc limit 1;
  for t in select unnest(array[
    'esporte_secretaria','esporte_modalidades','esporte_categorias','esporte_equipes','esporte_profissionais',
    'esporte_atletas','esporte_escolinhas','esporte_projetos','esporte_treinamentos','esporte_competicoes',
    'esporte_jogos','esporte_resultados','esporte_eventos','esporte_inscricoes','esporte_arbitragem',
    'esporte_espacos','esporte_reservas','esporte_manutencao','esporte_materiais','esporte_uniformes',
    'esporte_estoque','esporte_estoque_mov','esporte_transporte','esporte_frota','esporte_frota_abastecimentos',
    'esporte_frota_manutencoes','esporte_avaliacoes','esporte_bolsas','esporte_convenios','esporte_patrocinios',
    'esporte_programas','esporte_financeiro','esporte_compras','esporte_contratos','esporte_metas',
    'esporte_indicadores','esporte_alertas','esporte_documentos','esporte_auditoria'
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
