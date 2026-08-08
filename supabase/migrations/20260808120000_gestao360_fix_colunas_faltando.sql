-- Colunas que o front-end já usava mas ficaram de fora da reconstrução do schema
alter table gestao360.promessas_campanha add column if not exists descricao text;
alter table gestao360.oportunidades_recursos add column if not exists link_edital text;

-- O grant de INSERT em manifestacoes não pegou na reconstrução original
-- (avaliacoes e evento_avaliacoes, que vieram no mesmo GRANT, funcionaram normal)
grant insert on gestao360.manifestacoes to anon, authenticated;
notify pgrst, 'reload schema';
