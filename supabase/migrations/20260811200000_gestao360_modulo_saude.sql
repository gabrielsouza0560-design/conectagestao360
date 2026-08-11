-- =============================================================
-- MÓDULO SAÚDE — Secretaria Municipal de Saúde
-- Schema: gestao360 (integrado ao sistema existente)
-- =============================================================

-- 1. Secretaria
create table if not exists gestao360.saude_secretaria (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null default 'Secretaria Municipal de Saúde',
  cnpj text,
  secretario text,
  secretario_adjunto text,
  endereco text,
  telefone text,
  whatsapp text,
  email text,
  horario_atendimento text,
  responsaveis text,
  setores text,
  logo_url text,
  observacoes text,
  meta_anual numeric(14,2),
  orcamento_anual numeric(14,2),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz
);

-- 2. Unidades de Saúde
create table if not exists gestao360.saude_unidades (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  tipo text not null default 'ubs' check (tipo in ('ubs','unidade_basica','posto','odontologica','farmacia','centro_especialidades','apoio','outro')),
  cnes text,
  endereco text,
  bairro text,
  telefone text,
  email text,
  responsavel text,
  horario_funcionamento text,
  dias_atendimento text,
  servicos text,
  capacidade_atendimento integer,
  populacao_referencia integer,
  ativa boolean not null default true,
  criado_em timestamptz not null default now()
);

-- 3. Equipes
create table if not exists gestao360.saude_equipes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  unidade_id uuid references gestao360.saude_unidades(id),
  nome text not null,
  tipo text,
  responsavel text,
  criado_em timestamptz not null default now()
);

-- 4. Profissionais
create table if not exists gestao360.saude_profissionais (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  unidade_id uuid references gestao360.saude_unidades(id),
  equipe_id uuid references gestao360.saude_equipes(id),
  nome text not null,
  matricula text,
  cargo text,
  funcao text,
  especialidade text,
  conselho text,
  registro_conselho text,
  carga_horaria integer,
  horario_trabalho text,
  data_admissao date,
  situacao text not null default 'ativo' check (situacao in ('ativo','afastado','ferias','inativo')),
  criado_em timestamptz not null default now()
);

-- 5. Pacientes (LGPD — sem CPF em texto claro)
create table if not exists gestao360.saude_pacientes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  codigo text,
  nome text not null,
  data_nascimento date,
  sexo text check (sexo in ('M','F','I')),
  bairro text,
  unidade_referencia_id uuid references gestao360.saude_unidades(id),
  data_cadastro date default current_date,
  situacao text not null default 'ativo' check (situacao in ('ativo','inativo','obito','mudou')),
  sus_cartao text,
  telefone text,
  criado_em timestamptz not null default now()
);

-- 6. Consultas
create table if not exists gestao360.saude_consultas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  paciente_id uuid references gestao360.saude_pacientes(id),
  unidade_id uuid references gestao360.saude_unidades(id),
  profissional_id uuid references gestao360.saude_profissionais(id),
  especialidade text,
  data date not null,
  horario time,
  tipo text default 'primeira_vez' check (tipo in ('primeira_vez','retorno','urgencia','demanda_espontanea')),
  situacao text not null default 'agendada' check (situacao in ('agendada','confirmada','realizada','cancelada','faltou','reagendada')),
  tempo_espera_min integer,
  encaminhamento text,
  retorno date,
  observacoes text,
  criado_em timestamptz not null default now()
);

-- 7. Atendimentos
create table if not exists gestao360.saude_atendimentos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  paciente_id uuid references gestao360.saude_pacientes(id),
  unidade_id uuid references gestao360.saude_unidades(id),
  profissional_id uuid references gestao360.saude_profissionais(id),
  tipo text default 'medico' check (tipo in ('enfermagem','medico','procedimento','curativo','afericao','domiciliar','demanda_espontanea','outro')),
  data date not null default current_date,
  descricao text,
  observacoes text,
  criado_em timestamptz not null default now()
);

-- 8. Exames
create table if not exists gestao360.saude_exames (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  paciente_id uuid references gestao360.saude_pacientes(id),
  tipo_exame text not null,
  unidade_solicitante_id uuid references gestao360.saude_unidades(id),
  profissional_solicitante_id uuid references gestao360.saude_profissionais(id),
  data_solicitacao date not null default current_date,
  prioridade text default 'normal' check (prioridade in ('normal','urgente','emergencia')),
  data_agendamento date,
  data_realizacao date,
  local text,
  prestador text,
  situacao text not null default 'solicitado' check (situacao in ('solicitado','agendado','realizado','cancelado','pendente')),
  criado_em timestamptz not null default now()
);

-- 9. Odontologia
create table if not exists gestao360.saude_odontologia (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  paciente_id uuid references gestao360.saude_pacientes(id),
  profissional_id uuid references gestao360.saude_profissionais(id),
  unidade_id uuid references gestao360.saude_unidades(id),
  data date not null default current_date,
  tipo_atendimento text,
  procedimento text,
  tratamento text,
  encaminhamento text,
  retorno date,
  situacao text default 'realizado' check (situacao in ('agendado','realizado','cancelado','faltou')),
  criado_em timestamptz not null default now()
);

-- 10. Vacinas (catálogo)
create table if not exists gestao360.saude_vacinas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  fabricante text,
  doses_esquema integer default 1,
  publico_alvo text,
  criado_em timestamptz not null default now()
);

-- 11. Vacinação (aplicações)
create table if not exists gestao360.saude_vacinacao (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  vacina_id uuid references gestao360.saude_vacinas(id),
  dose integer default 1,
  paciente_id uuid references gestao360.saude_pacientes(id),
  data date not null default current_date,
  unidade_id uuid references gestao360.saude_unidades(id),
  profissional_id uuid references gestao360.saude_profissionais(id),
  lote text,
  validade date,
  campanha text,
  criado_em timestamptz not null default now()
);

-- 12. Estoque de vacinas
create table if not exists gestao360.saude_vacina_estoque (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  vacina_id uuid references gestao360.saude_vacinas(id),
  unidade_id uuid references gestao360.saude_unidades(id),
  lote text,
  validade date,
  quantidade_recebida integer default 0,
  quantidade_aplicada integer default 0,
  quantidade_perdida integer default 0,
  criado_em timestamptz not null default now()
);

-- 13. Medicamentos (catálogo)
create table if not exists gestao360.saude_medicamentos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  principio_ativo text,
  apresentacao text,
  unidade_medida text default 'comprimido',
  estoque_minimo integer default 0,
  estoque_maximo integer,
  valor_unitario numeric(10,2),
  criado_em timestamptz not null default now()
);

-- 14. Farmácia movimentações
create table if not exists gestao360.saude_farmacia_mov (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  medicamento_id uuid references gestao360.saude_medicamentos(id),
  unidade_id uuid references gestao360.saude_unidades(id),
  tipo text not null check (tipo in ('entrada','saida','dispensacao','ajuste','perda')),
  quantidade integer not null,
  lote text,
  validade date,
  fornecedor text,
  paciente_id uuid references gestao360.saude_pacientes(id),
  data date not null default current_date,
  observacoes text,
  criado_em timestamptz not null default now()
);

-- 15. Visitas domiciliares
create table if not exists gestao360.saude_visitas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  profissional_id uuid references gestao360.saude_profissionais(id),
  equipe_id uuid references gestao360.saude_equipes(id),
  paciente_id uuid references gestao360.saude_pacientes(id),
  data date not null default current_date,
  localidade text,
  tipo_visita text,
  motivo text,
  atendimento_realizado text,
  encaminhamento text,
  retorno_necessario boolean default false,
  criado_em timestamptz not null default now()
);

-- 16. Encaminhamentos
create table if not exists gestao360.saude_encaminhamentos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  paciente_id uuid references gestao360.saude_pacientes(id),
  especialidade text not null,
  profissional_solicitante_id uuid references gestao360.saude_profissionais(id),
  data date not null default current_date,
  prioridade text default 'normal' check (prioridade in ('normal','urgente','emergencia')),
  motivo text,
  unidade_destino text,
  situacao text not null default 'pendente' check (situacao in ('pendente','agendado','realizado','cancelado')),
  data_agendamento date,
  data_atendimento date,
  criado_em timestamptz not null default now()
);

-- 17. Regulação
create table if not exists gestao360.saude_regulacao (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  paciente_id uuid references gestao360.saude_pacientes(id),
  especialidade text not null,
  prioridade text default 'normal' check (prioridade in ('normal','urgente','emergencia')),
  data_entrada date not null default current_date,
  situacao text not null default 'aguardando' check (situacao in ('aguardando','agendado','atendido','cancelado')),
  data_agendamento date,
  data_atendimento date,
  observacoes text,
  criado_em timestamptz not null default now()
);

-- 18. Frota (veículos)
create table if not exists gestao360.saude_frota (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  veiculo text not null,
  placa text,
  modelo text,
  marca text,
  ano integer,
  km_atual numeric(10,1) default 0,
  combustivel text default 'flex',
  motorista_responsavel text,
  seguro_vencimento date,
  licenciamento_vencimento date,
  situacao text not null default 'ativo' check (situacao in ('ativo','em_manutencao','inativo')),
  criado_em timestamptz not null default now()
);

-- 19. Transporte
create table if not exists gestao360.saude_transporte (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  paciente_id uuid references gestao360.saude_pacientes(id),
  data date not null default current_date,
  horario time,
  destino text not null,
  motivo text,
  veiculo_id uuid references gestao360.saude_frota(id),
  motorista text,
  passageiros integer default 1,
  km_inicial numeric(10,1),
  km_final numeric(10,1),
  combustivel_litros numeric(6,1),
  custo numeric(10,2),
  situacao text default 'agendada' check (situacao in ('agendada','realizada','cancelada')),
  criado_em timestamptz not null default now()
);

-- 20. Abastecimentos da frota
create table if not exists gestao360.saude_frota_abastecimentos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  veiculo_id uuid references gestao360.saude_frota(id),
  data date not null default current_date,
  km numeric(10,1),
  litros numeric(8,2),
  valor numeric(10,2),
  posto text,
  criado_em timestamptz not null default now()
);

-- 21. Manutenções da frota
create table if not exists gestao360.saude_frota_manutencoes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  veiculo_id uuid references gestao360.saude_frota(id),
  data date not null default current_date,
  tipo text,
  descricao text,
  valor numeric(10,2),
  oficina text,
  km numeric(10,1),
  criado_em timestamptz not null default now()
);

-- 22. Estoque geral
create table if not exists gestao360.saude_estoque (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  material text not null,
  categoria text,
  unidade_medida text default 'unidade',
  estoque_minimo integer default 0,
  estoque_maximo integer,
  localizacao text,
  criado_em timestamptz not null default now()
);

-- 23. Movimentações do estoque
create table if not exists gestao360.saude_estoque_mov (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  estoque_id uuid references gestao360.saude_estoque(id),
  tipo text not null check (tipo in ('entrada','saida','ajuste','perda')),
  quantidade integer not null,
  lote text,
  validade date,
  data date not null default current_date,
  observacoes text,
  criado_em timestamptz not null default now()
);

-- 24. Compras
create table if not exists gestao360.saude_compras (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  solicitacao text,
  processo text,
  item text not null,
  quantidade integer,
  cotacao numeric(10,2),
  fornecedor text,
  valor numeric(12,2),
  data date default current_date,
  empenho text,
  situacao text default 'solicitada' check (situacao in ('solicitada','em_cotacao','empenhada','entregue','cancelada')),
  criado_em timestamptz not null default now()
);

-- 25. Contratos
create table if not exists gestao360.saude_contratos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  numero text,
  processo text,
  fornecedor text not null,
  cnpj text,
  objeto text,
  valor numeric(14,2),
  data_inicio date,
  data_fim date,
  fiscal text,
  saldo numeric(14,2),
  situacao text default 'vigente' check (situacao in ('vigente','encerrado','aditado','rescindido')),
  criado_em timestamptz not null default now()
);

-- 26. Programas de Saúde
create table if not exists gestao360.saude_programas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  descricao text,
  publico_alvo text,
  responsavel text,
  unidade_id uuid references gestao360.saude_unidades(id),
  meta text,
  periodo text,
  orcamento numeric(12,2),
  resultado text,
  criado_em timestamptz not null default now()
);

-- 27. Campanhas
create table if not exists gestao360.saude_campanhas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  tipo text,
  data date,
  local text,
  publico_alvo text,
  equipe text,
  meta integer,
  atendimentos integer default 0,
  resultado text,
  materiais text,
  custo numeric(10,2),
  criado_em timestamptz not null default now()
);

-- 28. Metas
create table if not exists gestao360.saude_metas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  indicador text not null,
  meta_anual numeric(12,2),
  meta_mensal numeric(12,2),
  meta_trimestral numeric(12,2),
  unidade_id uuid references gestao360.saude_unidades(id),
  profissional_id uuid references gestao360.saude_profissionais(id),
  resultado numeric(12,2) default 0,
  percentual numeric(5,1) default 0,
  situacao text default 'abaixo' check (situacao in ('atingida','atencao','abaixo')),
  periodo text,
  criado_em timestamptz not null default now()
);

-- 29. Indicadores configuração
create table if not exists gestao360.saude_indicadores_config (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  descricao text,
  formula text,
  fonte text,
  periodicidade text default 'mensal',
  meta numeric(12,2),
  unidade_medida text,
  responsavel text,
  criado_em timestamptz not null default now()
);

-- 30. Alertas configuração
create table if not exists gestao360.saude_alertas_config (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  tipo text not null,
  descricao text,
  tabela_ref text,
  campo_ref text,
  limite numeric,
  ativo boolean default true,
  criado_em timestamptz not null default now()
);

-- 31. Alertas gerados
create table if not exists gestao360.saude_alertas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  tipo text not null,
  mensagem text not null,
  severidade text default 'atencao' check (severidade in ('info','atencao','critico')),
  lido boolean default false,
  referencia_id uuid,
  criado_em timestamptz not null default now()
);

-- ====================== RLS ======================
alter table gestao360.saude_secretaria enable row level security;
alter table gestao360.saude_unidades enable row level security;
alter table gestao360.saude_equipes enable row level security;
alter table gestao360.saude_profissionais enable row level security;
alter table gestao360.saude_pacientes enable row level security;
alter table gestao360.saude_consultas enable row level security;
alter table gestao360.saude_atendimentos enable row level security;
alter table gestao360.saude_exames enable row level security;
alter table gestao360.saude_odontologia enable row level security;
alter table gestao360.saude_vacinas enable row level security;
alter table gestao360.saude_vacinacao enable row level security;
alter table gestao360.saude_vacina_estoque enable row level security;
alter table gestao360.saude_medicamentos enable row level security;
alter table gestao360.saude_farmacia_mov enable row level security;
alter table gestao360.saude_visitas enable row level security;
alter table gestao360.saude_encaminhamentos enable row level security;
alter table gestao360.saude_regulacao enable row level security;
alter table gestao360.saude_frota enable row level security;
alter table gestao360.saude_transporte enable row level security;
alter table gestao360.saude_frota_abastecimentos enable row level security;
alter table gestao360.saude_frota_manutencoes enable row level security;
alter table gestao360.saude_estoque enable row level security;
alter table gestao360.saude_estoque_mov enable row level security;
alter table gestao360.saude_compras enable row level security;
alter table gestao360.saude_contratos enable row level security;
alter table gestao360.saude_programas enable row level security;
alter table gestao360.saude_campanhas enable row level security;
alter table gestao360.saude_metas enable row level security;
alter table gestao360.saude_indicadores_config enable row level security;
alter table gestao360.saude_alertas_config enable row level security;
alter table gestao360.saude_alertas enable row level security;

-- Policies (mesmo padrão do sistema existente: tenant scope)
do $$
declare
  t text;
begin
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
    execute format(
      'create policy "tenant_iso_%1$s" on gestao360.%1$s for all using (tenant_id = gestao360.jwt_tenant_id()) with check (tenant_id = gestao360.jwt_tenant_id())',
      t
    );
  end loop;
end$$;

-- ====================== GRANTS ======================
grant usage on schema gestao360 to authenticated, anon;

grant select, insert, update, delete on
  gestao360.saude_secretaria,
  gestao360.saude_unidades,
  gestao360.saude_equipes,
  gestao360.saude_profissionais,
  gestao360.saude_pacientes,
  gestao360.saude_consultas,
  gestao360.saude_atendimentos,
  gestao360.saude_exames,
  gestao360.saude_odontologia,
  gestao360.saude_vacinas,
  gestao360.saude_vacinacao,
  gestao360.saude_vacina_estoque,
  gestao360.saude_medicamentos,
  gestao360.saude_farmacia_mov,
  gestao360.saude_visitas,
  gestao360.saude_encaminhamentos,
  gestao360.saude_regulacao,
  gestao360.saude_frota,
  gestao360.saude_transporte,
  gestao360.saude_frota_abastecimentos,
  gestao360.saude_frota_manutencoes,
  gestao360.saude_estoque,
  gestao360.saude_estoque_mov,
  gestao360.saude_compras,
  gestao360.saude_contratos,
  gestao360.saude_programas,
  gestao360.saude_campanhas,
  gestao360.saude_metas,
  gestao360.saude_indicadores_config,
  gestao360.saude_alertas_config,
  gestao360.saude_alertas
to authenticated;

notify pgrst, 'reload schema';
