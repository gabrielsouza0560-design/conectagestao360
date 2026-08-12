-- Importa dados reais dos relatórios "Sala do Empreendedor 2026 — Ivatuba" e
-- "Fomento Paraná — Ivatuba" (gerados em 12/08/2026) pro módulo Indústria e Comércio,
-- em formato editável — dá pra continuar atualizando mês a mês pela tela normal.

-- Sala do Empreendedor não tinha um lugar pra guardar totais mensais por serviço
-- (só atendimento individual). Cria uma tabela nova, própria pra isso.
create table if not exists gestao360.ic_atendimentos_mensal (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  servico text not null,
  ano integer not null default extract(year from now())::integer,
  jan integer default 0, fev integer default 0, mar integer default 0, abr integer default 0,
  mai integer default 0, jun integer default 0, jul integer default 0, ago integer default 0,
  set integer default 0, out integer default 0, nov integer default 0, dez integer default 0,
  total integer default 0,
  criado_em timestamptz not null default now()
);
alter table gestao360.ic_atendimentos_mensal enable row level security;
drop policy if exists tenant_iso on gestao360.ic_atendimentos_mensal;
create policy tenant_iso on gestao360.ic_atendimentos_mensal for all
  using (tenant_id = gestao360.jwt_tenant_id()) with check (tenant_id = gestao360.jwt_tenant_id());
grant select, insert, update, delete on gestao360.ic_atendimentos_mensal to authenticated;

insert into gestao360.ic_atendimentos_mensal (tenant_id,servico,ano,jan,fev,mar,abr,mai,jun,jul,ago,set,out,nov,dez,total) values
('00000000-0000-0000-0000-000000000001','Alteração de Dados',2026,1,0,0,0,0,0,0,0,0,0,0,0,1),
('00000000-0000-0000-0000-000000000001','Baixa da Inscrição do MEI (CNPJ)',2026,0,0,0,1,0,0,0,0,0,0,0,0,1),
('00000000-0000-0000-0000-000000000001','Boleto DAS - (INSS/ICMS/ISS)',2026,83,117,28,64,38,57,114,0,0,0,0,0,501),
('00000000-0000-0000-0000-000000000001','CNPJ MEI',2026,1,2,0,0,0,0,0,0,0,0,0,0,3),
('00000000-0000-0000-0000-000000000001','Compras Públicas',2026,7,7,9,0,17,30,16,0,0,0,0,0,86),
('00000000-0000-0000-0000-000000000001','Crédito',2026,7,2,5,0,0,8,17,0,0,0,0,0,39),
('00000000-0000-0000-0000-000000000001','Declaração Anual - DASN-SIMEI',2026,36,43,5,2,6,4,7,0,0,0,0,0,103),
('00000000-0000-0000-0000-000000000001','Nota Fiscal MEI - SERVIÇO (ISS)',2026,21,20,10,0,0,0,0,0,0,0,0,0,51),
('00000000-0000-0000-0000-000000000001','Orientações sobre o MEI',2026,2,3,0,0,0,0,0,0,0,0,0,0,5),
('00000000-0000-0000-0000-000000000001','Parcelamento Especial - Microempreendedor Individual',2026,2,1,0,0,0,0,0,0,0,0,0,0,3),
('00000000-0000-0000-0000-000000000001','Parcelamento - Microempreendedor Individual',2026,3,0,2,0,0,2,1,0,0,0,0,0,8);

-- Fomento Paraná: 28 pedidos reais do relatório. "Valor concedido" no relatório é, na
-- verdade, o valor solicitado em todos os casos (soma bate com o TOTAL CONCEDIDO de
-- R$873.000,00 somando as 28 linhas) — valor_aprovado só é preenchido pros concedidos.
insert into gestao360.ic_fomento (tenant_id,empreendedor,identificacao,tipo_credito,valor_solicitado,valor_aprovado,data,situacao,acompanhamento) values
('00000000-0000-0000-0000-000000000001','SOLANGE APARECIDA JORGE NAZARI','325805 · 57.650.402/0001-59','Capital de giro',250000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','SOLANGE APARECIDA JORGE NAZARI','322027 · 57.650.402/0001-59','Capital de giro',63000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','MOLINA & BARBOSA LTDA','322176 · 00.942.430/0001-22','Capital de giro',60000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','PAULO RAFAEL DANTE','329569 · 055.784.329-48','Microcrédito',10000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','DRIELLE TOMAZ LINO','327603 · 62.687.734/0001-48','Microcrédito',15000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','NATAN TAMIOSO DUTRA','324306 · 22.254.004/0001-39','Microcrédito',20000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','SAUL VICTOR DANDOLINI MONTEIRO','325902 · 14.569.884/0001-04','Microcrédito',20000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','ROSELI CARREIRA','318014 · 59.084.537/0001-20','Microcrédito',20000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','NATALINO PAIVA','318001 · 21.716.924/0001-69','Microcrédito',20000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','M. L. S. DE SOUZA & CIA LTDA','330108 · 11.925.648/0001-95','Microcrédito',30000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','FERNANDA SILVA MECATTI','326438 · 049.812.329-42','Microcrédito',10000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','RAYANE MONIQUE DE OLIVEIRA DIAS','331103 · 103.182.319-05','Microcrédito',10000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','IVETE APARECIDA DANTE','331053 · 616.623.569-00','Microcrédito',10000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','LIDIANI MALFATO','331048 · 033.918.819-76','Microcrédito',10000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','VALERIA DOS SANTOS DA SILVA','330920 · 018.587.489-41','Microcrédito',5000.00,null,'2026-08-05','negada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','A ROZANI COMERCIO E VAREJO DE PNEUMATICOS E SERVIÇOS DE BORRACHARIA E MECANICA EM GERAL','332583 · 51.905.559/0001-00','Microcrédito',20000.00,null,'2026-08-05','analise','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026. Status na origem: Em processo.'),
('00000000-0000-0000-0000-000000000001','PAULO HENRIQUE PEREIRA MACHADO','321874 · 30.662.942/0001-04','Capital de giro',60000.00,null,'2026-08-05','analise','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026. Status na origem: Em processo.'),
('00000000-0000-0000-0000-000000000001','FRANCIELI BARBOSA SILVERIO','326423 · 18.236.776/0001-70','Microcrédito',20000.00,20000.00,'2026-08-05','aprovada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','IVANETE PEREIRA LOIOLA','325337 · 18.321.516/0001-01','Microcrédito',20000.00,20000.00,'2026-08-05','aprovada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','JOAO VITOR DANTE','324457 · 42.931.687/0001-29','Microcrédito',15000.00,15000.00,'2026-08-05','aprovada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','AMARILDO LAVEZO','318789 · 27.099.281/0001-38','Microcrédito',20000.00,20000.00,'2026-08-05','aprovada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','LIDIANI MALFATO','329981 · 61.470.881/0001-07','Microcrédito',20000.00,20000.00,'2026-08-05','aprovada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','MADALENA QUINELLI LOIOLA','330581 · 22.143.722/0001-38','Microcrédito',15000.00,15000.00,'2026-08-05','aprovada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','VILMA APARECIDA MARTINS CARDOSO','331616 · 17.977.876/0001-95','Microcrédito',20000.00,20000.00,'2026-08-05','aprovada','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026.'),
('00000000-0000-0000-0000-000000000001','MOLINA & BARBOSA LTDA','330150 · 00.942.430/0001-22','Capital de giro',60000.00,null,'2026-08-05','analise','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026. Status na origem: Em processo.'),
('00000000-0000-0000-0000-000000000001','ROSILAINE DE FATIMA DANTE MURATA','330110 · 006.292.179-71','Microcrédito',10000.00,null,'2026-08-05','analise','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026. Status na origem: Em processo.'),
('00000000-0000-0000-0000-000000000001','ANDREIA APARECIDA DOS SANTOS','330271 · 19.538.212/0001-55','Microcrédito',20000.00,null,'2026-08-05','analise','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026. Status na origem: Em processo.'),
('00000000-0000-0000-0000-000000000001','DELMA RODRIGUES FERREIRA','331893 · 29.606.384/0001-72','Microcrédito',20000.00,null,'2026-08-05','analise','Importado do relatório Fomento Paraná — Ivatuba, gerado 12/08/2026. Status na origem: Em processo.');

notify pgrst, 'reload schema';
