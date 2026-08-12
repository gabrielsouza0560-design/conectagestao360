-- Leitura pública (site sem login) para a Secretaria de Esporte: competições, jogos,
-- resultados, modalidades/categorias, escolinhas, espaços esportivos e dados
-- institucionais da secretaria. Tabelas com dado pessoal (esporte_atletas: contato,
-- responsável, escola, bairro, data de nascimento — inclui menores de idade) NÃO
-- ganham leitura pública direta; em vez disso, uma view expõe só o que é seguro
-- (nome, modalidade, categoria, equipe, nível) pra aparecer em "atletas de destaque".

create or replace view gestao360.esporte_atletas_publico as
  select id, tenant_id, nome, modalidade_id, categoria_id, equipe_id, nivel_esportivo, situacao
  from gestao360.esporte_atletas
  where situacao = 'ativo';

grant select on gestao360.esporte_atletas_publico to anon, authenticated;

do $$
declare t text;
begin
  for t in select unnest(array[
    'esporte_secretaria','esporte_modalidades','esporte_categorias','esporte_equipes',
    'esporte_escolinhas','esporte_competicoes','esporte_jogos','esporte_resultados',
    'esporte_espacos','esporte_eventos'
  ])
  loop
    execute format('drop policy if exists select_public on gestao360.%I', t);
    execute format('create policy select_public on gestao360.%I for select to anon, authenticated using (true)', t);
    execute format('grant select on gestao360.%I to anon', t);
  end loop;
end$$;

notify pgrst, 'reload schema';
