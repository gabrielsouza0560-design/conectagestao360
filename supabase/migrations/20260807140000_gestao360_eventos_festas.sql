-- ============================================================
-- Eventos/Festas (ex.: Secretaria de Indústria e Comércio)
-- ============================================================
-- NOTA: se você migrou para um projeto Supabase novo usando
-- 20260807150000_gestao360_reconstrucao_completa.sql, NÃO rode este
-- arquivo também — o conteúdo dele já está incluído lá dentro. Este
-- arquivo só é útil se você aplicar direto no projeto antigo (via CLI,
-- linkado a fclpcdtnmlpjfgovubra).
-- Este arquivo foi escrito FORA de uma sessão com acesso direto ao banco
-- (sem Supabase MCP conectado). As políticas de RLS abaixo assumem que o
-- hook de JWT injeta as claims `perfil`, `tenant_id` e `secretaria_id`
-- diretamente no token (conforme documentado em docs/ESTADO_ATUAL.md).
-- ANTES DE RODAR EM PRODUÇÃO: confira essas policies contra as já
-- existentes em `acoes`/`avaliacoes`/`manifestacoes` (idealmente pedindo
-- pro Claude Code puxar as migrations reais via `supabase db pull` ou MCP)
-- e ajuste os nomes de claim/roles se estiverem diferentes.

-- ---------- Campos novos em acoes (reutilizável para qualquer evento) ----------
alter table gestao360.acoes
  add column if not exists eh_evento boolean not null default false,
  add column if not exists publico_estimado integer,
  add column if not exists valor_retorno_estimado numeric(14,2);

-- ---------- Fotos e vídeos do evento ----------
create table if not exists gestao360.evento_midias (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  tipo text not null check (tipo in ('foto','video')),
  storage_path text not null,
  url text not null,
  criado_em timestamptz not null default now()
);

alter table gestao360.evento_midias enable row level security;

-- leitura pública (as mídias aparecem no relatório do evento)
create policy evento_midias_select_public on gestao360.evento_midias
  for select
  to anon, authenticated
  using (true);

-- inserção só por quem tem perfil de gestão na mesma secretaria/tenant da ação
create policy evento_midias_insert_staff on gestao360.evento_midias
  for insert
  to authenticated
  with check (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    and (auth.jwt() ->> 'perfil') in ('admin_master','prefeito','secretario','diretor','coordenador')
    and exists (
      select 1 from gestao360.acoes a
      where a.id = acao_id
        and a.tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
        and (
          (auth.jwt() ->> 'perfil') = 'admin_master'
          or a.secretaria_id = (auth.jwt() ->> 'secretaria_id')::uuid
        )
    )
  );

grant select on gestao360.evento_midias to anon, authenticated;
grant insert on gestao360.evento_midias to authenticated;

-- ---------- Avaliação pública do evento (população x comerciantes/barracas) ----------
create table if not exists gestao360.evento_avaliacoes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  tipo_avaliador text not null check (tipo_avaliador in ('morador','comerciante')),
  nota numeric(3,1) not null check (nota >= 0 and nota <= 10),
  comentario text,
  criado_em timestamptz not null default now()
);

alter table gestao360.evento_avaliacoes enable row level security;

-- qualquer pessoa pode avaliar (link público/QR code, sem login)
create policy evento_avaliacoes_insert_public on gestao360.evento_avaliacoes
  for insert
  to anon, authenticated
  with check (true);

-- leitura pública dos resultados agregados (transparência)
create policy evento_avaliacoes_select_public on gestao360.evento_avaliacoes
  for select
  to anon, authenticated
  using (true);

grant select, insert on gestao360.evento_avaliacoes to anon, authenticated;

-- ---------- Storage bucket para fotos/vídeos dos eventos ----------
insert into storage.buckets (id, name, public)
values ('evento-midias', 'evento-midias', true)
on conflict (id) do nothing;

create policy evento_midias_storage_select on storage.objects
  for select
  to anon, authenticated
  using (bucket_id = 'evento-midias');

create policy evento_midias_storage_insert on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'evento-midias'
    and (auth.jwt() ->> 'perfil') in ('admin_master','prefeito','secretario','diretor','coordenador')
  );
