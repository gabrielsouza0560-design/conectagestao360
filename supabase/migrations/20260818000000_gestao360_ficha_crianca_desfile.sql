-- Ficha completa da criança do desfile
alter table gestao360.evento_desfile_criancas
  add column if not exists data_nascimento date,
  add column if not exists idade integer,
  add column if not exists escola text,
  add column if not exists serie text,
  add column if not exists responsavel_nome text,
  add column if not exists responsavel_parentesco text,
  add column if not exists responsavel_whatsapp text,
  add column if not exists responsavel_endereco text,
  add column if not exists gosta_de_fazer text,
  add column if not exists sonho text,
  add column if not exists sobre_a_crianca text;

-- Ficha completa dos patrocinadores/lojas parceiras
alter table gestao360.evento_patrocinios
  add column if not exists razao_social text,
  add column if not exists nome_fantasia text,
  add column if not exists endereco text,
  add column if not exists quantidade_pecas integer;

notify pgrst, 'reload schema';
