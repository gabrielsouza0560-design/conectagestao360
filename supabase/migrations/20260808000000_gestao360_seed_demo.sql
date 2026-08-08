-- ============================================================
-- Dados de demonstração (para o projeto novo, kfvkembarvsbtveksiag)
-- ============================================================

insert into gestao360.acoes (tenant_id, secretaria_id, titulo, descricao, ano, data, bairro, valor_investido, origem_recurso, status, quantidade_beneficiados, publicada_no_portal)
values
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Saúde'), 'Reforma da UBS Vila Nova', 'Reforma completa da Unidade Básica de Saúde, ampliando o atendimento à população da região.', 2026, '2026-03-10', 'Vila Nova', 480000, 'Recurso próprio', 'concluido', 8000, true),
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Obras e Serviços Públicos'), 'Pavimentação da Av. Brasil', 'Recapeamento asfáltico e sinalização de 2,3 km da avenida principal do Centro.', 2026, '2026-05-02', 'Centro', 2100000, 'Convênio Estadual', 'em_andamento', 15000, true),
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Educação'), 'Nova Escola do Jardim Sul', 'Construção de escola municipal com 12 salas de aula, quadra coberta e refeitório.', 2026, '2026-02-15', 'Jardim Sul', 3800000, 'Emenda Federal', 'concluido', 600, true),
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Meio Ambiente'), 'Mutirão de Plantio de Árvores', 'Plantio de 2.000 mudas nativas em praças e margens de rios do município.', 2026, '2026-06-05', 'Diversos bairros', 45000, 'Recurso próprio', 'concluido', 30000, true),
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Indústria e Comércio'), 'Feira do Comerciante 2026', 'Feira anual de exposição e vendas dos comerciantes e produtores locais, com praça de alimentação, shows e barracas.', 2026, '2026-07-20', 'Centro', 50000, 'Emenda parlamentar federal', 'concluido', 3000, true);

update gestao360.acoes
set eh_evento = true, publico_estimado = 3000, valor_retorno_estimado = 120000
where titulo = 'Feira do Comerciante 2026';

insert into gestao360.indicadores (tenant_id, secretaria_id, chave, valor) values
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Educação'), 'alunos_atendidos', 14230),
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Saúde'), 'consultas_realizadas', 89400),
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Saúde'), 'medicamentos_distribuidos', 52000),
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Obras e Serviços Públicos'), 'estradas_recuperadas_km', 38),
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Meio Ambiente'), 'arvores_plantadas', 2000),
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Cultura'), 'eventos_realizados', 24),
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Indústria e Comércio'), 'empregos_gerados', 340),
  ('00000000-0000-0000-0000-000000000001', (select id from gestao360.secretarias where nome = 'Indústria e Comércio'), 'empresas_abertas', 58);

insert into gestao360.mapa_pontos (tenant_id, categoria, nome, latitude, longitude) values
  ('00000000-0000-0000-0000-000000000001', 'ubs', 'UBS Vila Nova', -25.4284, -49.2733),
  ('00000000-0000-0000-0000-000000000001', 'escola', 'Escola Municipal Jardim Sul', -25.4310, -49.2790),
  ('00000000-0000-0000-0000-000000000001', 'obra', 'Pavimentação Av. Brasil', -25.4250, -49.2700),
  ('00000000-0000-0000-0000-000000000001', 'praca', 'Praça Central', -25.4265, -49.2715);

insert into gestao360.promessas_campanha (tenant_id, titulo, eixo, ano_previsto, status) values
  ('00000000-0000-0000-0000-000000000001', 'Reformar todas as UBS da rede municipal', 'Saúde', 2027, 'em_andamento'),
  ('00000000-0000-0000-0000-000000000001', 'Implantar Portal da Transparência', 'Gestão e Transparência', 2025, 'cumprida'),
  ('00000000-0000-0000-0000-000000000001', 'Pavimentar 100% das ruas do Centro', 'Infraestrutura', 2028, 'em_andamento');

insert into gestao360.publicacoes (tenant_id, titulo, corpo, tipo, status_aprovacao, publicado_em) values
  ('00000000-0000-0000-0000-000000000001', 'Reforma da UBS Vila Nova é concluída', 'Unidade reformada amplia atendimento à população da região.', 'noticia', 'aprovado', now()),
  ('00000000-0000-0000-0000-000000000001', 'Matrículas abertas para o ano letivo', 'Rede municipal amplia vagas em creches e ensino fundamental.', 'noticia', 'aprovado', now());
