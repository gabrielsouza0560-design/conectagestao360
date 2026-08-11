-- Módulo Educação — Secretaria Municipal de Educação
-- 37 tabelas com RLS e isolamento por tenant

-- 1. Secretaria
CREATE TABLE IF NOT EXISTS gestao360.ed_secretaria (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  nome text,
  cnpj text,
  secretario text,
  secretario_adjunto text,
  endereco text,
  telefone text,
  whatsapp text,
  email text,
  horario_atendimento text,
  responsaveis_setores text,
  organograma text,
  programas text,
  orcamento_anual numeric(18,2),
  meta_anual numeric(18,2),
  observacoes text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 2. Escolas
CREATE TABLE IF NOT EXISTS gestao360.ed_escolas (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  nome text NOT NULL,
  codigo_inep text,
  cnpj text,
  endereco text,
  bairro text,
  telefone text,
  email text,
  diretor text,
  coordenador text,
  modalidade text,
  niveis_ensino text,
  turnos text,
  numero_salas integer,
  capacidade integer,
  numero_alunos integer,
  numero_professores integer,
  biblioteca boolean DEFAULT false,
  laboratorio boolean DEFAULT false,
  quadra boolean DEFAULT false,
  cozinha boolean DEFAULT false,
  refeitorio boolean DEFAULT false,
  banheiros text,
  acessibilidade boolean DEFAULT false,
  internet boolean DEFAULT false,
  computadores integer,
  climatizacao boolean DEFAULT false,
  situacao_estrutura text,
  observacoes text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 3. Alunos
CREATE TABLE IF NOT EXISTS gestao360.ed_alunos (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  identificador text,
  nome text NOT NULL,
  data_nascimento date,
  sexo text,
  escola_id uuid,
  turma text,
  serie_ano text,
  turno text,
  data_matricula date,
  situacao text DEFAULT 'ativo',
  bairro text,
  responsavel text,
  contatos text,
  transporte boolean DEFAULT false,
  alimentacao boolean DEFAULT true,
  atendimento_especializado boolean DEFAULT false,
  info_educacionais text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 4. Matrículas
CREATE TABLE IF NOT EXISTS gestao360.ed_matriculas (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  aluno_id uuid,
  escola_id uuid,
  ano_letivo text,
  serie text,
  turma text,
  turno text,
  data date,
  situacao text DEFAULT 'ativa',
  transferencia boolean DEFAULT false,
  remanejamento boolean DEFAULT false,
  cancelamento boolean DEFAULT false,
  motivo text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 5. Vagas e lista de espera
CREATE TABLE IF NOT EXISTS gestao360.ed_vagas (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  escola_id uuid,
  serie text,
  turma text,
  turno text,
  vagas_disponiveis integer,
  vagas_ocupadas integer,
  capacidade integer,
  lista_espera integer DEFAULT 0,
  data_solicitacao date,
  prioridade text,
  situacao text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 6. Turmas
CREATE TABLE IF NOT EXISTS gestao360.ed_turmas (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  escola_id uuid,
  serie_ano text,
  turma text NOT NULL,
  sala text,
  turno text,
  professor_responsavel text,
  quantidade_alunos integer,
  capacidade integer,
  disciplinas text,
  horarios text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 7. Professores
CREATE TABLE IF NOT EXISTS gestao360.ed_professores (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  nome text NOT NULL,
  matricula text,
  cargo text,
  funcao text,
  formacao text,
  graduacao text,
  especializacao text,
  disciplina text,
  escola_id uuid,
  turma text,
  carga_horaria integer,
  jornada text,
  turno text,
  data_admissao date,
  situacao text DEFAULT 'ativo',
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 8. Servidores da Educação
CREATE TABLE IF NOT EXISTS gestao360.ed_servidores (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  nome text NOT NULL,
  cargo text,
  funcao text,
  setor text,
  escola_id uuid,
  carga_horaria integer,
  situacao text DEFAULT 'ativo',
  data_admissao date,
  observacoes text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 9. Frequência
CREATE TABLE IF NOT EXISTS gestao360.ed_frequencia (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  aluno_id uuid,
  escola_id uuid,
  turma text,
  data date,
  disciplina text,
  presenca boolean DEFAULT true,
  falta boolean DEFAULT false,
  falta_justificada boolean DEFAULT false,
  motivo text,
  criado_em timestamptz DEFAULT now()
);

-- 10. Avaliações e Notas
CREATE TABLE IF NOT EXISTS gestao360.ed_avaliacoes (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  aluno_id uuid,
  escola_id uuid,
  turma text,
  disciplina text,
  avaliacao text,
  periodo text,
  nota numeric(5,2),
  media numeric(5,2),
  recuperacao numeric(5,2),
  resultado text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 11. Aprendizagem
CREATE TABLE IF NOT EXISTS gestao360.ed_aprendizagem (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  escola_id uuid,
  turma text,
  serie text,
  disciplina text,
  avaliacao_diagnostica text,
  habilidade text,
  competencia text,
  resultado text,
  intervencao text,
  acompanhamento text,
  evolucao text,
  meta text,
  periodo text,
  ano text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 12. Educação Infantil
CREATE TABLE IF NOT EXISTS gestao360.ed_educacao_infantil (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  escola_id uuid,
  tipo text,
  criancas_matriculadas integer,
  vagas integer,
  lista_espera integer DEFAULT 0,
  frequencia_media numeric(5,2),
  turmas integer,
  profissionais integer,
  alimentacao text,
  atividades text,
  atendimento text,
  capacidade integer,
  observacoes text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 13. Educação Especial
CREATE TABLE IF NOT EXISTS gestao360.ed_educacao_especial (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  aluno_id uuid,
  escola_id uuid,
  atendimento_especializado text,
  profissional_apoio text,
  sala_recursos boolean DEFAULT false,
  recursos_necessarios text,
  atendimento text,
  frequencia text,
  acompanhamento text,
  encaminhamentos text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 14. Transporte Escolar
CREATE TABLE IF NOT EXISTS gestao360.ed_transporte (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  aluno_id uuid,
  escola_id uuid,
  rota text,
  veiculo text,
  motorista text,
  monitor text,
  ponto_embarque text,
  destino text,
  horario text,
  quilometragem numeric(12,2),
  passageiros integer,
  situacao text DEFAULT 'ativo',
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 15. Frota
CREATE TABLE IF NOT EXISTS gestao360.ed_frota (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  veiculo text NOT NULL,
  placa text,
  modelo text,
  marca text,
  ano integer,
  capacidade integer,
  quilometragem numeric(12,2),
  combustivel text,
  motorista text,
  seguro text,
  licenciamento text,
  situacao text DEFAULT 'ativo',
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 16. Frota Abastecimentos
CREATE TABLE IF NOT EXISTS gestao360.ed_frota_abastecimentos (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  veiculo_id uuid,
  data date,
  combustivel text,
  litros numeric(10,2),
  valor numeric(12,2),
  quilometragem numeric(12,2),
  posto text,
  motorista text,
  criado_em timestamptz DEFAULT now()
);

-- 17. Frota Manutenções
CREATE TABLE IF NOT EXISTS gestao360.ed_frota_manutencoes (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  veiculo_id uuid,
  data date,
  tipo text,
  descricao text,
  oficina text,
  valor numeric(12,2),
  quilometragem numeric(12,2),
  situacao text DEFAULT 'realizada',
  criado_em timestamptz DEFAULT now()
);

-- 18. Alimentação Escolar
CREATE TABLE IF NOT EXISTS gestao360.ed_alimentacao (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  escola_id uuid,
  cardapio text,
  data date,
  refeicao text,
  quantidade_planejada integer,
  quantidade_preparada integer,
  quantidade_servida integer,
  alunos_atendidos integer,
  ingredientes text,
  fornecedor text,
  custo numeric(12,2),
  desperdicio text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 19. Estoque
CREATE TABLE IF NOT EXISTS gestao360.ed_estoque (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  produto text NOT NULL,
  categoria text,
  unidade text,
  quantidade numeric(12,2),
  estoque_minimo numeric(12,2),
  estoque_maximo numeric(12,2),
  entrada numeric(12,2),
  saida numeric(12,2),
  saldo numeric(12,2),
  validade date,
  localizacao text,
  fornecedor text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 20. Biblioteca
CREATE TABLE IF NOT EXISTS gestao360.ed_biblioteca (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  titulo text NOT NULL,
  autor text,
  categoria text,
  isbn text,
  quantidade integer,
  escola_id uuid,
  localizacao text,
  emprestimo date,
  devolucao date,
  aluno text,
  situacao text DEFAULT 'disponivel',
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 21. Tecnologia
CREATE TABLE IF NOT EXISTS gestao360.ed_tecnologia (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  tipo text NOT NULL,
  patrimonio text,
  numero_serie text,
  escola_id uuid,
  localizacao text,
  data_aquisicao date,
  valor numeric(12,2),
  situacao text DEFAULT 'funcionando',
  manutencao text,
  responsavel text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 22. Infraestrutura
CREATE TABLE IF NOT EXISTS gestao360.ed_infraestrutura (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  escola_id uuid,
  salas text,
  banheiros text,
  cozinha text,
  refeitorio text,
  quadra text,
  biblioteca text,
  laboratorio text,
  telhado text,
  pintura text,
  iluminacao text,
  eletrica text,
  hidraulica text,
  internet text,
  climatizacao text,
  seguranca text,
  acessibilidade text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 23. Manutenção
CREATE TABLE IF NOT EXISTS gestao360.ed_manutencao (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  escola_id uuid,
  problema text NOT NULL,
  prioridade text,
  data date,
  responsavel text,
  orcamento numeric(12,2),
  execucao text,
  conclusao date,
  custo numeric(12,2),
  situacao text DEFAULT 'aberta',
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 24. Programas
CREATE TABLE IF NOT EXISTS gestao360.ed_programas (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  nome text NOT NULL,
  objetivo text,
  publico text,
  escola text,
  responsavel text,
  periodo text,
  meta text,
  orcamento numeric(12,2),
  atividades text,
  participantes integer,
  resultado text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 25. Projetos
CREATE TABLE IF NOT EXISTS gestao360.ed_projetos (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  nome text NOT NULL,
  objetivo text,
  publico text,
  escola text,
  responsavel text,
  periodo text,
  meta text,
  orcamento numeric(12,2),
  atividades text,
  participantes integer,
  resultado text,
  situacao text DEFAULT 'em_andamento',
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 26. Eventos
CREATE TABLE IF NOT EXISTS gestao360.ed_eventos (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  evento text NOT NULL,
  escola text,
  data date,
  responsavel text,
  participantes integer,
  atividades text,
  custo numeric(12,2),
  resultado text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 27. Família e Comunidade
CREATE TABLE IF NOT EXISTS gestao360.ed_familia (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  tipo text,
  escola_id uuid,
  data date,
  participacao integer,
  responsaveis integer,
  atendimentos text,
  encaminhamentos text,
  acoes text,
  comunicacao text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 28. Ocorrências
CREATE TABLE IF NOT EXISTS gestao360.ed_ocorrencias (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  data date,
  escola_id uuid,
  aluno_id uuid,
  tipo text,
  descricao text,
  providencia text,
  responsavel text,
  encaminhamento text,
  situacao text DEFAULT 'aberta',
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 29. Compras
CREATE TABLE IF NOT EXISTS gestao360.ed_compras (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  solicitacao text,
  processo text,
  item text NOT NULL,
  quantidade numeric(12,2),
  cotacao numeric(12,2),
  fornecedor text,
  valor numeric(12,2),
  data date,
  entrega date,
  nota_fiscal text,
  situacao text DEFAULT 'pendente',
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 30. Contratos
CREATE TABLE IF NOT EXISTS gestao360.ed_contratos (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  numero text,
  processo text,
  fornecedor text NOT NULL,
  cnpj text,
  objeto text,
  valor numeric(18,2),
  data_inicio date,
  data_fim date,
  fiscal text,
  saldo numeric(18,2),
  situacao text DEFAULT 'vigente',
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 31. Financeiro
CREATE TABLE IF NOT EXISTS gestao360.ed_financeiro (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  tipo text NOT NULL,
  descricao text,
  valor numeric(18,2),
  programa text,
  projeto text,
  fonte_recurso text,
  fornecedor text,
  contrato text,
  data date,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 32. Metas
CREATE TABLE IF NOT EXISTS gestao360.ed_metas (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  indicador text NOT NULL,
  meta_anual numeric(12,2),
  meta_mensal numeric(12,2),
  meta_trimestral numeric(12,2),
  meta_escola text,
  meta_programa text,
  responsavel text,
  prazo date,
  resultado numeric(12,2),
  percentual numeric(5,2),
  periodo text,
  situacao text DEFAULT 'em_andamento',
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 33. Indicadores
CREATE TABLE IF NOT EXISTS gestao360.ed_indicadores (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  nome text NOT NULL,
  descricao text,
  formula text,
  fonte text,
  periodicidade text,
  meta numeric(12,2),
  resultado numeric(12,2),
  unidade_medida text,
  responsavel text,
  status text,
  historico text,
  criado_em timestamptz DEFAULT now(),
  atualizado_em timestamptz DEFAULT now()
);

-- 34. Alertas Config
CREATE TABLE IF NOT EXISTS gestao360.ed_alertas_config (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  tipo text NOT NULL,
  limite numeric(12,2),
  severidade text DEFAULT 'atencao',
  ativo boolean DEFAULT true,
  criado_em timestamptz DEFAULT now()
);

-- 35. Alertas
CREATE TABLE IF NOT EXISTS gestao360.ed_alertas (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  tipo text,
  mensagem text NOT NULL,
  severidade text DEFAULT 'info',
  modulo text,
  lido boolean DEFAULT false,
  criado_em timestamptz DEFAULT now()
);

-- 36. Documentos
CREATE TABLE IF NOT EXISTS gestao360.ed_documentos (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  titulo text NOT NULL,
  tipo text,
  descricao text,
  modulo text,
  url text,
  data date,
  criado_em timestamptz DEFAULT now()
);

-- 37. Auditoria
CREATE TABLE IF NOT EXISTS gestao360.ed_auditoria (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL,
  usuario text,
  acao text,
  modulo text,
  registro_id uuid,
  dados_anteriores jsonb,
  dados_novos jsonb,
  data timestamptz DEFAULT now()
);

-- RLS
DO $$
DECLARE t text;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'ed_secretaria','ed_escolas','ed_alunos','ed_matriculas','ed_vagas',
    'ed_turmas','ed_professores','ed_servidores','ed_frequencia','ed_avaliacoes',
    'ed_aprendizagem','ed_educacao_infantil','ed_educacao_especial','ed_transporte',
    'ed_frota','ed_frota_abastecimentos','ed_frota_manutencoes','ed_alimentacao',
    'ed_estoque','ed_biblioteca','ed_tecnologia','ed_infraestrutura','ed_manutencao',
    'ed_programas','ed_projetos','ed_eventos','ed_familia','ed_ocorrencias',
    'ed_compras','ed_contratos','ed_financeiro','ed_metas','ed_indicadores',
    'ed_alertas_config','ed_alertas','ed_documentos','ed_auditoria'
  ])
  LOOP
    EXECUTE format('ALTER TABLE gestao360.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('DROP POLICY IF EXISTS %I ON gestao360.%I', t||'_tenant', t);
    EXECUTE format(
      'CREATE POLICY %I ON gestao360.%I FOR ALL TO authenticated USING (tenant_id = gestao360.jwt_tenant_id()) WITH CHECK (tenant_id = gestao360.jwt_tenant_id())',
      t||'_tenant', t
    );
    EXECUTE format('GRANT ALL ON gestao360.%I TO authenticated', t);
  END LOOP;
END$$;
