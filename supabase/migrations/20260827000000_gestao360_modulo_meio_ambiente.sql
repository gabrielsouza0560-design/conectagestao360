-- =============================================================
-- MÓDULO MEIO AMBIENTE — Secretaria Municipal de Meio Ambiente
-- Schema: gestao360 (mesmo padrão de Saúde/Educação/Indústria e Comércio/Esporte/Agricultura/Cultura/Assistência Social)
-- =============================================================

create table if not exists gestao360.ma_secretaria (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null default 'Secretaria Municipal de Meio Ambiente', cnpj text, secretario text, secretario_adjunto text,
  endereco text, telefone text, whatsapp text, email text, horario_atendimento text, responsaveis_setores text,
  setores text, orcamento_anual numeric(14,2), meta_anual numeric(14,2), observacoes text,
  criado_em timestamptz not null default now(), atualizado_em timestamptz
);

create table if not exists gestao360.ma_areas_verdes (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, tipo text check (tipo in ('area_verde','praca','parque','bosque')),
  localizacao text, latitude numeric(10,6), longitude numeric(10,6), area numeric(10,2), vegetacao text,
  infraestrutura text, situacao text default 'conservada' check (situacao in ('conservada','manutencao_pendente','degradada')),
  responsavel text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_arvores (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  localizacao text not null, latitude numeric(10,6), longitude numeric(10,6), especie text, porte text,
  condicao text default 'boa' check (condicao in ('boa','regular','risco')), idade_estimada integer,
  necessidade_poda boolean default false, data_plantio date, situacao text default 'ativa',
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_podas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  arvore_id uuid references gestao360.ma_arvores(id), localizacao text, motivo text, data date default current_date,
  equipe text, responsavel text, custo numeric(10,2),
  situacao text default 'solicitada' check (situacao in ('solicitada','agendada','realizada','pendente')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_supressao (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  localizacao text not null, motivo text, especie text, autorizacao text, responsavel text, data date,
  compensacao_ambiental text, situacao text default 'solicitada' check (situacao in ('solicitada','autorizada','negada','executada')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_plantio (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  local text not null, especie text, quantidade integer, data date default current_date, responsavel text,
  projeto text, origem_mudas text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_viveiro (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  especie text not null, quantidade_produzida integer default 0, quantidade_disponivel integer default 0,
  origem text, entrada integer default 0, saida integer default 0, perdas integer default 0,
  distribuicao text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_recursos_hidricos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  identificacao text not null, tipo text check (tipo in ('nascente','rio','corrego','reservatorio','poco')),
  localizacao text, latitude numeric(10,6), longitude numeric(10,6), propriedade text,
  situacao text default 'preservada' check (situacao in ('preservada','em_risco','degradada','recuperada')),
  protecao boolean default false, vegetacao text, intervencao text, monitoramento text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_qualidade_agua (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  ponto_coleta text not null, data date default current_date, parametro text, resultado numeric(10,3),
  unidade text, responsavel text, situacao text default 'dentro_padrao' check (situacao in ('dentro_padrao','atencao','fora_padrao')),
  documento_laudo text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_residuos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text check (tipo in ('domiciliar','reciclavel','organico','construcao_civil','poda','volumoso','eletronico','outro')),
  origem text, quantidade_toneladas numeric(10,3), destino text, responsavel text, data date default current_date,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_coleta (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text check (tipo in ('lixo','seletiva')), rota text not null, bairro text, frequencia text,
  veiculo text, equipe text, cooperativa text, horario text, quantidade_coletada numeric(10,3),
  situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_catadores (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  cooperativa_associacao text not null, integrantes integer, contato text, materiais text,
  volume_coletado numeric(10,3), parcerias text, apoio_municipal text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_ecopontos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, localizacao text, latitude numeric(10,6), longitude numeric(10,6), responsavel text,
  tipos_residuos_aceitos text, capacidade text, volume_recebido numeric(10,3), situacao text default 'ativo',
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_compostagem (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  unidade text not null, capacidade text, residuos_recebidos numeric(10,3), quantidade_composto_produzido numeric(10,3),
  destino text, situacao text default 'ativa', criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_fauna (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  especie text not null, ocorrencia text, localizacao text, data date default current_date,
  situacao text default 'em_analise' check (situacao in ('em_analise','encaminhada','resolvida')),
  encaminhamento text, orgao_responsavel text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_animais (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text check (tipo in ('castracao','bem_estar')), animal_especie text, localizacao text,
  campanha text, data date default current_date, procedimento text, profissional text,
  identificacao text, custo numeric(10,2), encaminhamento text,
  situacao text default 'realizado', criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_fiscalizacao (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  local text not null, data date default current_date, tipo text, responsavel text, vistoria text,
  providencia text, prazo date, resultado text, situacao text default 'aberta' check (situacao in ('aberta','em_andamento','concluida')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_ocorrencias (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  origem text check (origem in ('denuncia','ocorrencia')),
  tipo text check (tipo in ('descarte_irregular','queimada','poluicao','corte_irregular','maus_tratos','erosao','assoreamento','danos_ambientais','outro')),
  protocolo text, local text not null, data date default current_date, descricao text,
  prioridade text default 'normal' check (prioridade in ('normal','alta','urgente')), responsavel text,
  providencia text, resultado text,
  situacao text default 'pendente' check (situacao in ('pendente','em_andamento','atendida','arquivada')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_licenciamento (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  empreendimento_solicitante text not null,
  tipo text check (tipo in ('licenciamento','autorizacao')),
  processo text, protocolo text, data date default current_date, documentos text, analise text,
  validade date, responsavel text,
  situacao text default 'em_analise' check (situacao in ('em_analise','deferido','indeferido','vencido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_vistorias (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  processo text, local text not null, data date default current_date, fiscal text, motivo text,
  resultado text, irregularidades text, prazo date, retorno date, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_multas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  processo text, ocorrencia_id uuid references gestao360.ma_ocorrencias(id), fundamento_legal text,
  valor numeric(12,2), data date default current_date,
  situacao text default 'aplicada' check (situacao in ('aplicada','recurso','paga','cancelada')),
  documento text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_educacao_ambiental (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  atividade text not null, tipo text check (tipo in ('acao_educativa','campanha')),
  local_escola text, publico text, data date default current_date, tema text, participantes integer,
  custo numeric(10,2), resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_projetos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, objetivo text, local text, responsavel text, periodo text, orcamento numeric(14,2),
  parceiros text, meta text, resultado text,
  situacao text default 'em_andamento' check (situacao in ('em_andamento','concluido','cancelado')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_recuperacao (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  area text not null, problema text, extensao numeric(10,2), projeto text, acao text, responsavel text,
  custo numeric(12,2), resultado text,
  situacao text default 'em_andamento' check (situacao in ('em_andamento','concluida')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_queimadas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  localizacao text not null, latitude numeric(10,6), longitude numeric(10,6), data date default current_date,
  area_estimada numeric(10,2), origem text, atendimento text, responsavel text, resultado text,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_poluicao (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text not null, local text, data date default current_date, origem text, vistoria text,
  providencia text, resultado text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_sustentabilidade (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  projeto text not null, area text check (area in ('energia','agua','residuos','reciclagem','eficiencia','arborizacao','mobilidade','educacao')),
  recursos_aplicados numeric(12,2), economia_gerada numeric(12,2), resultado text,
  situacao text default 'em_andamento', criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_mudancas_climaticas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  risco_ocorrencia text not null, area_vulneravel text, data date, acao_preventiva text, projeto text,
  situacao text default 'monitorado', criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_energia (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  unidade text not null, consumo_kwh numeric(12,2), periodo text, custo numeric(10,2), fonte text,
  equipamento text, projeto_eficiencia text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_convenios (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  parceiro text not null, objeto text, valor numeric(14,2), data_inicio date, data_fim date, contrapartida text,
  responsavel text, situacao text default 'vigente' check (situacao in ('vigente','encerrado','vencido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_financeiro (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text check (tipo in ('receita','despesa','empenho','liquidacao','pagamento')), descricao text,
  valor numeric(14,2), programa text, servico text, fonte_recurso text, fornecedor text, contrato text, data date,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_compras (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  solicitacao text, processo text, item text not null, quantidade integer, cotacao numeric(10,2), fornecedor text,
  valor numeric(12,2), data date default current_date, entrega date, nota_fiscal text,
  situacao text default 'solicitada' check (situacao in ('solicitada','em_cotacao','empenhada','entregue','cancelada')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_contratos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  numero text, processo text, fornecedor text not null, cnpj text, objeto text, valor numeric(14,2),
  data_inicio date, data_fim date, fiscal text, saldo numeric(14,2),
  situacao text default 'vigente' check (situacao in ('vigente','encerrado','aditado','rescindido')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_metas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  indicador text not null, periodo text, meta_anual numeric(12,2), meta_mensal numeric(12,2), responsavel text,
  prazo date, resultado numeric(12,2), percentual numeric(5,1) default 0,
  situacao text default 'em_andamento' check (situacao in ('atingida','atencao','abaixo','em_andamento')),
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_indicadores (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  nome text not null, descricao text, formula text, fonte text, periodicidade text default 'mensal',
  meta numeric(12,2), resultado numeric(12,2), unidade_medida text, responsavel text, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_documentos (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  titulo text not null, tipo text, descricao text, modulo text, url text, data date default current_date,
  criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_alertas (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  tipo text, mensagem text not null, severidade text default 'atencao' check (severidade in ('info','atencao','critico')),
  lido boolean default false, referencia_id uuid, criado_em timestamptz not null default now()
);

create table if not exists gestao360.ma_auditoria (
  id uuid primary key default gen_random_uuid(), tenant_id uuid not null references gestao360.tenants(id),
  usuario text, data timestamptz default now(), acao text not null, modulo text, registro_id uuid,
  valor_anterior text, valor_novo text
);

-- ====================== RLS (isolado à secretaria "Meio Ambiente" + Admin Master/Prefeito/Chefe de Gabinete) ======================
do $$
declare t text; sec_id uuid;
begin
  select id into sec_id from gestao360.secretarias where nome ilike '%meio ambiente%' order by criado_em asc limit 1;
  for t in select unnest(array[
    'ma_secretaria','ma_areas_verdes','ma_arvores','ma_podas','ma_supressao','ma_plantio','ma_viveiro',
    'ma_recursos_hidricos','ma_qualidade_agua','ma_residuos','ma_coleta','ma_catadores','ma_ecopontos',
    'ma_compostagem','ma_fauna','ma_animais','ma_fiscalizacao','ma_ocorrencias','ma_licenciamento',
    'ma_vistorias','ma_multas','ma_educacao_ambiental','ma_projetos','ma_recuperacao','ma_queimadas',
    'ma_poluicao','ma_sustentabilidade','ma_mudancas_climaticas','ma_energia','ma_convenios','ma_financeiro',
    'ma_compras','ma_contratos','ma_metas','ma_indicadores','ma_documentos','ma_alertas','ma_auditoria'
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
