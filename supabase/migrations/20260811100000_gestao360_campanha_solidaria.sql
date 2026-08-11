-- Campanha Solidária: controle de doações por criança do desfile
-- Mínimo: 50 itens alimentícios não perecíveis OU R$250 em doações financeiras (ou combinação)
-- Arrecadação destinada integralmente à APAE

alter table gestao360.evento_desfile_criancas
  add column if not exists doacao_itens_alimentos integer not null default 0,
  add column if not exists doacao_valor_financeiro numeric(10,2) not null default 0,
  add column if not exists meta_atingida boolean not null default false,
  add column if not exists autorizado boolean not null default false;

notify pgrst, 'reload schema';
