-- Suporte a relatório por campeonato: artilheiro, cartões/expulsões e goleiro
-- menos vazado. Precisa de dois dados que ainda não existiam:
-- 1) posição do atleta (pra saber quem é goleiro);
-- 2) eventos do jogo (gol, cartão amarelo, cartão vermelho), lançados por atleta.

alter table gestao360.esporte_atletas add column if not exists posicao text;

create table if not exists gestao360.esporte_jogo_eventos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  jogo_id uuid references gestao360.esporte_jogos(id) on delete cascade,
  competicao_id uuid references gestao360.esporte_competicoes(id),
  equipe_id uuid references gestao360.esporte_equipes(id),
  atleta_id uuid references gestao360.esporte_atletas(id),
  tipo text not null check (tipo in ('gol','cartao_amarelo','cartao_vermelho')),
  minuto integer,
  criado_em timestamptz not null default now()
);

do $$
declare sec_id uuid;
begin
  select id into sec_id from gestao360.secretarias where nome = 'Esporte' order by criado_em asc limit 1;
  alter table gestao360.esporte_jogo_eventos enable row level security;
  drop policy if exists tenant_iso on gestao360.esporte_jogo_eventos;
  execute format(
    'create policy tenant_iso on gestao360.esporte_jogo_eventos for all using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L)) with check (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_total() or gestao360.jwt_secretaria_id() = %L))',
    sec_id, sec_id
  );
  grant select, insert, update, delete on gestao360.esporte_jogo_eventos to authenticated;
end$$;

-- Leitura pública dos eventos (gols e cartões já são de conhecimento público em
-- qualquer súmula de jogo) pra alimentar o "Relatório do campeonato" na página
-- pública também, além da atualiza a view de atletas com a posição.
drop policy if exists select_public on gestao360.esporte_jogo_eventos;
create policy select_public on gestao360.esporte_jogo_eventos for select to anon, authenticated using (true);
grant select on gestao360.esporte_jogo_eventos to anon;

create or replace view gestao360.esporte_atletas_publico as
  select id, tenant_id, nome, modalidade_id, categoria_id, equipe_id, nivel_esportivo, posicao, situacao
  from gestao360.esporte_atletas
  where situacao = 'ativo';

grant select on gestao360.esporte_atletas_publico to anon, authenticated;

notify pgrst, 'reload schema';
