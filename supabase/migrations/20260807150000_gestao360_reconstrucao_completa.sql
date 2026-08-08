-- ============================================================
-- Conecta Gestão — reconstrução completa do schema gestao360
-- ============================================================
-- Escrito por reconstrução (sem acesso direto ao banco de origem, que fica
-- misturado com o projeto "Ray Modas"). Baseado em tudo que o código das
-- telas (HTML) realmente lê/grava — não é uma cópia exata da estrutura
-- original, é uma reconstrução funcional equivalente.
--
-- COMO USAR: cole este arquivo inteiro no SQL Editor de um projeto Supabase
-- NOVO e VAZIO (Dashboard → SQL Editor → New query → Run). Depois siga os
-- passos manuais no final do arquivo (Auth Hook + primeiro Admin Master).
-- ============================================================

create extension if not exists pgcrypto;

create schema if not exists gestao360;

-- ---------- Tabelas núcleo ----------

create table gestao360.tenants (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  criado_em timestamptz not null default now()
);

create table gestao360.perfis (
  id uuid primary key default gen_random_uuid(),
  nome text not null unique,
  descricao text
);

create table gestao360.secretarias (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  sigla text,
  ativa boolean not null default true,
  criado_em timestamptz not null default now()
);

create table gestao360.categorias (
  id uuid primary key default gen_random_uuid(),
  nome text not null unique
);

create table gestao360.usuarios (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null unique references auth.users(id) on delete cascade,
  tenant_id uuid not null references gestao360.tenants(id),
  nome text not null,
  email text,
  perfil_id uuid references gestao360.perfis(id),
  secretaria_id uuid references gestao360.secretarias(id),
  status text not null default 'pendente' check (status in ('pendente','ativo','inativo')),
  criado_em timestamptz not null default now()
);

-- ---------- Ações de governo ----------

create table gestao360.acoes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  secretaria_id uuid not null references gestao360.secretarias(id),
  categoria_id uuid references gestao360.categorias(id),
  titulo text not null,
  descricao text,
  ano integer not null,
  data date,
  bairro text,
  latitude numeric(10,6),
  longitude numeric(10,6),
  valor_investido numeric(14,2) default 0,
  origem_recurso text,
  convenio text,
  processo text,
  empresa text,
  status text not null default 'planejado' check (status in ('planejado','em_andamento','concluido','cancelado')),
  quantidade_beneficiados integer,
  observacoes text,
  publicada_no_portal boolean not null default false,
  eh_evento boolean not null default false,
  publico_estimado integer,
  valor_retorno_estimado numeric(14,2),
  criado_em timestamptz not null default now()
);

create table gestao360.acao_midias (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  tipo text not null check (tipo in ('foto','video')),
  url text not null,
  ordem integer default 0,
  criado_em timestamptz not null default now()
);

create table gestao360.acao_anexos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  nome text not null,
  url text not null,
  publico boolean not null default false,
  criado_em timestamptz not null default now()
);

-- ---------- Participação pública ----------

create table gestao360.publicacoes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  titulo text not null,
  corpo text,
  tipo text,
  status_aprovacao text not null default 'rascunho' check (status_aprovacao in ('rascunho','aprovado','recusado')),
  publicado_em timestamptz,
  criado_em timestamptz not null default now()
);

create table gestao360.indicadores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  secretaria_id uuid references gestao360.secretarias(id),
  chave text not null,
  valor numeric(18,2) not null default 0,
  criado_em timestamptz not null default now()
);

create table gestao360.mapa_pontos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  categoria text not null,
  nome text not null,
  latitude numeric(10,6),
  longitude numeric(10,6),
  criado_em timestamptz not null default now()
);

create table gestao360.promessas_campanha (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  titulo text not null,
  eixo text,
  ano_previsto integer,
  status text not null default 'nao_iniciada' check (status in ('nao_iniciada','em_andamento','parcialmente_cumprida','cumprida')),
  criado_em timestamptz not null default now()
);

create table gestao360.avaliacoes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  secretaria_id uuid references gestao360.secretarias(id),
  nota numeric(3,1) not null check (nota >= 0 and nota <= 10),
  comentario text,
  criado_em timestamptz not null default now()
);

create table gestao360.manifestacoes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  secretaria_id uuid references gestao360.secretarias(id),
  tipo text not null check (tipo in ('sugestao','elogio','critica','reclamacao','pedido_melhoria','denuncia','solicitacao')),
  descricao text,
  identificado boolean not null default false,
  nome_cidadao text,
  foto_url text,
  latitude numeric(10,6),
  longitude numeric(10,6),
  criado_em timestamptz not null default now()
);

-- ---------- Notificações internas ----------

create table gestao360.notificacoes (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references gestao360.usuarios(id) on delete cascade,
  titulo text not null,
  corpo text,
  lida boolean not null default false,
  criado_em timestamptz not null default now()
);

-- ---------- Captação de recursos ----------

create table gestao360.oportunidades_recursos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  secretaria_id uuid references gestao360.secretarias(id),
  programa text not null,
  orgao_concedente text,
  esfera text check (esfera in ('Federal','Estadual','Municipal','Privado/ONG')),
  valor_estimado numeric(14,2),
  prazo_submissao date,
  status text not null default 'prospectando' check (status in ('prospectando','em_elaboracao','submetido','aprovado','reprovado','em_execucao','concluido')),
  requisitos text,
  criado_em timestamptz not null default now()
);

create table gestao360.recursos_referencia_estadual (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  objeto text not null,
  orgao_concedente text,
  valor numeric(14,2),
  situacao text,
  data_referencia date,
  ano integer,
  importado_em timestamptz not null default now()
);

-- ---------- Permissões (matriz perfil x permissão) ----------

create table gestao360.permissoes (
  id uuid primary key default gen_random_uuid(),
  modulo text not null,
  chave text not null unique,
  descricao text
);

create table gestao360.perfil_permissoes (
  perfil_id uuid not null references gestao360.perfis(id) on delete cascade,
  permissao_id uuid not null references gestao360.permissoes(id) on delete cascade,
  concedida boolean not null default true,
  primary key (perfil_id, permissao_id)
);

-- ---------- Auditoria (estrutura pronta, ainda sem tela de consulta) ----------

create table gestao360.logs_auditoria (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  usuario_id uuid references gestao360.usuarios(id),
  entidade text not null,
  entidade_id uuid,
  acao text not null,
  detalhes jsonb,
  criado_em timestamptz not null default now()
);

-- ---------- Eventos/Festas ----------

create table gestao360.evento_midias (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  tipo text not null check (tipo in ('foto','video')),
  storage_path text not null,
  url text not null,
  criado_em timestamptz not null default now()
);

create table gestao360.evento_avaliacoes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references gestao360.tenants(id),
  acao_id uuid not null references gestao360.acoes(id) on delete cascade,
  tipo_avaliador text not null check (tipo_avaliador in ('morador','comerciante')),
  nota numeric(3,1) not null check (nota >= 0 and nota <= 10),
  comentario text,
  criado_em timestamptz not null default now()
);

-- ============================================================
-- RLS
-- ============================================================

alter table gestao360.tenants enable row level security;
alter table gestao360.perfis enable row level security;
alter table gestao360.secretarias enable row level security;
alter table gestao360.categorias enable row level security;
alter table gestao360.usuarios enable row level security;
alter table gestao360.acoes enable row level security;
alter table gestao360.acao_midias enable row level security;
alter table gestao360.acao_anexos enable row level security;
alter table gestao360.publicacoes enable row level security;
alter table gestao360.indicadores enable row level security;
alter table gestao360.mapa_pontos enable row level security;
alter table gestao360.promessas_campanha enable row level security;
alter table gestao360.avaliacoes enable row level security;
alter table gestao360.manifestacoes enable row level security;
alter table gestao360.notificacoes enable row level security;
alter table gestao360.oportunidades_recursos enable row level security;
alter table gestao360.recursos_referencia_estadual enable row level security;
alter table gestao360.permissoes enable row level security;
alter table gestao360.perfil_permissoes enable row level security;
alter table gestao360.logs_auditoria enable row level security;
alter table gestao360.evento_midias enable row level security;
alter table gestao360.evento_avaliacoes enable row level security;

-- helpers de leitura das claims do JWT (perfil / tenant_id / secretaria_id
-- injetadas pelo hook customizado — ver seção "PASSO MANUAL" no fim do arquivo)
create or replace function gestao360.jwt_perfil() returns text
  language sql stable as $$ select nullif(auth.jwt() ->> 'perfil', '') $$;
create or replace function gestao360.jwt_tenant_id() returns uuid
  language sql stable as $$ select nullif(auth.jwt() ->> 'tenant_id', '')::uuid $$;
create or replace function gestao360.jwt_secretaria_id() returns uuid
  language sql stable as $$ select nullif(auth.jwt() ->> 'secretaria_id', '')::uuid $$;

create or replace function gestao360.eh_gestao_ampla() returns boolean
  language sql stable as $$
    select gestao360.jwt_perfil() in ('admin_master','prefeito','vice_prefeito','controladoria','comunicacao')
  $$;

-- secretarias/categorias: leitura pública (usadas em telas sem login)
create policy secretarias_select_public on gestao360.secretarias for select to anon, authenticated using (true);
create policy categorias_select_public on gestao360.categorias for select to anon, authenticated using (true);
create policy secretarias_insert_admin on gestao360.secretarias for insert to authenticated
  with check (gestao360.jwt_perfil() = 'admin_master' and tenant_id = gestao360.jwt_tenant_id());

create policy perfis_select_authenticated on gestao360.perfis for select to authenticated using (true);
create policy permissoes_select_authenticated on gestao360.permissoes for select to authenticated using (true);
create policy perfil_permissoes_select_authenticated on gestao360.perfil_permissoes for select to authenticated using (true);

-- usuarios: cada um vê a si mesmo; admin_master vê e edita todo mundo do tenant
create policy usuarios_select_self on gestao360.usuarios for select to authenticated
  using (auth_user_id = auth.uid() or (gestao360.jwt_perfil() = 'admin_master' and tenant_id = gestao360.jwt_tenant_id()));
create policy usuarios_update_admin on gestao360.usuarios for update to authenticated
  using (gestao360.jwt_perfil() = 'admin_master' and tenant_id = gestao360.jwt_tenant_id());

-- acoes: leitura pública só do que está publicado; equipe vê o escopo dela
create policy acoes_select_public on gestao360.acoes for select to anon using (publicada_no_portal = true);
create policy acoes_select_staff on gestao360.acoes for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_ampla() or secretaria_id = gestao360.jwt_secretaria_id()));
create policy acoes_insert_staff on gestao360.acoes for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_ampla() or secretaria_id = gestao360.jwt_secretaria_id()));
create policy acoes_update_staff on gestao360.acoes for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_ampla() or secretaria_id = gestao360.jwt_secretaria_id()));

create policy acao_midias_select_public on gestao360.acao_midias for select to anon, authenticated using (true);
create policy acao_midias_insert_staff on gestao360.acao_midias for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id());
create policy acao_anexos_select_staff on gestao360.acao_anexos for select to authenticated using (tenant_id = gestao360.jwt_tenant_id());
create policy acao_anexos_select_public on gestao360.acao_anexos for select to anon using (publico = true);
create policy acao_anexos_insert_staff on gestao360.acao_anexos for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id());

-- publicações: público vê só aprovado; equipe do tenant gerencia
create policy publicacoes_select_public on gestao360.publicacoes for select to anon using (status_aprovacao = 'aprovado');
create policy publicacoes_select_staff on gestao360.publicacoes for select to authenticated using (tenant_id = gestao360.jwt_tenant_id());
create policy publicacoes_insert_staff on gestao360.publicacoes for insert to authenticated with check (tenant_id = gestao360.jwt_tenant_id());
create policy publicacoes_update_staff on gestao360.publicacoes for update to authenticated using (tenant_id = gestao360.jwt_tenant_id());

-- indicadores, mapa, promessas: leitura pública total (transparência)
create policy indicadores_select_public on gestao360.indicadores for select to anon, authenticated using (true);
create policy indicadores_insert_staff on gestao360.indicadores for insert to authenticated with check (tenant_id = gestao360.jwt_tenant_id());
create policy mapa_pontos_select_public on gestao360.mapa_pontos for select to anon, authenticated using (true);
create policy mapa_pontos_insert_staff on gestao360.mapa_pontos for insert to authenticated with check (tenant_id = gestao360.jwt_tenant_id());
create policy promessas_select_public on gestao360.promessas_campanha for select to anon, authenticated using (true);
create policy promessas_insert_gestao on gestao360.promessas_campanha for insert to authenticated
  with check (tenant_id = gestao360.jwt_tenant_id() and gestao360.jwt_perfil() in ('admin_master','prefeito'));
create policy promessas_update_gestao on gestao360.promessas_campanha for update to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and gestao360.jwt_perfil() in ('admin_master','prefeito'));

-- avaliações e manifestações: qualquer um envia (anônimo), só Prefeito/Admin leem
create policy avaliacoes_insert_public on gestao360.avaliacoes for insert to anon, authenticated with check (true);
create policy avaliacoes_select_gestao on gestao360.avaliacoes for select to authenticated
  using (gestao360.jwt_perfil() in ('admin_master','prefeito'));
create policy manifestacoes_insert_public on gestao360.manifestacoes for insert to anon, authenticated with check (true);
create policy manifestacoes_select_gestao on gestao360.manifestacoes for select to authenticated
  using (gestao360.jwt_perfil() in ('admin_master','prefeito'));

-- notificações: só o dono
create policy notificacoes_select_dono on gestao360.notificacoes for select to authenticated
  using (usuario_id in (select id from gestao360.usuarios where auth_user_id = auth.uid()));
create policy notificacoes_update_dono on gestao360.notificacoes for update to authenticated
  using (usuario_id in (select id from gestao360.usuarios where auth_user_id = auth.uid()));

-- captação de recursos: equipe do tenant/secretaria
create policy recursos_select_staff on gestao360.oportunidades_recursos for select to authenticated
  using (tenant_id = gestao360.jwt_tenant_id() and (gestao360.eh_gestao_ampla() or secretaria_id is null or secretaria_id = gestao360.jwt_secretaria_id()));
create policy recursos_insert_staff on gestao360.oportunidades_recursos for insert to authenticated with check (tenant_id = gestao360.jwt_tenant_id());
create policy recursos_update_staff on gestao360.oportunidades_recursos for update to authenticated using (tenant_id = gestao360.jwt_tenant_id());

create policy recursos_ref_select_staff on gestao360.recursos_referencia_estadual for select to authenticated using (tenant_id = gestao360.jwt_tenant_id());
create policy recursos_ref_insert_staff on gestao360.recursos_referencia_estadual for insert to authenticated with check (tenant_id = gestao360.jwt_tenant_id());

-- logs: só admin master lê
create policy logs_select_admin on gestao360.logs_auditoria for select to authenticated
  using (gestao360.jwt_perfil() = 'admin_master' and tenant_id = gestao360.jwt_tenant_id());

-- eventos (festas etc.)
create policy evento_midias_select_public on gestao360.evento_midias for select to anon, authenticated using (true);
create policy evento_midias_insert_staff on gestao360.evento_midias for insert to authenticated
  with check (
    tenant_id = gestao360.jwt_tenant_id()
    and exists (select 1 from gestao360.acoes a where a.id = acao_id and (gestao360.eh_gestao_ampla() or a.secretaria_id = gestao360.jwt_secretaria_id()))
  );
create policy evento_avaliacoes_insert_public on gestao360.evento_avaliacoes for insert to anon, authenticated with check (true);
create policy evento_avaliacoes_select_public on gestao360.evento_avaliacoes for select to anon, authenticated using (true);

-- ============================================================
-- Grants
-- ============================================================

grant usage on schema gestao360 to anon, authenticated;
grant select on gestao360.secretarias, gestao360.categorias, gestao360.acoes, gestao360.acao_midias, gestao360.acao_anexos,
  gestao360.publicacoes, gestao360.indicadores, gestao360.mapa_pontos, gestao360.promessas_campanha
  to anon, authenticated;
grant insert on gestao360.avaliacoes, gestao360.manifestacoes, gestao360.evento_avaliacoes to anon, authenticated;
grant select on gestao360.evento_avaliacoes, gestao360.evento_midias to anon, authenticated;
grant select, insert, update on gestao360.usuarios, gestao360.perfis, gestao360.permissoes, gestao360.perfil_permissoes,
  gestao360.notificacoes, gestao360.oportunidades_recursos, gestao360.recursos_referencia_estadual,
  gestao360.avaliacoes, gestao360.manifestacoes, gestao360.publicacoes, gestao360.indicadores,
  gestao360.mapa_pontos, gestao360.promessas_campanha, gestao360.acoes, gestao360.acao_midias, gestao360.acao_anexos,
  gestao360.logs_auditoria, gestao360.secretarias, gestao360.evento_midias
  to authenticated;

-- ============================================================
-- Funções RPC usadas pelas telas
-- ============================================================

create or replace function gestao360.autocadastrar_usuario(p_nome text, p_perfil_nome text, p_secretaria_id uuid)
returns void
language plpgsql security definer set search_path = gestao360, public
as $$
declare
  v_perfil_id uuid;
  v_tenant_id uuid;
begin
  select id into v_tenant_id from gestao360.tenants order by criado_em asc limit 1;
  select id into v_perfil_id from gestao360.perfis where nome = p_perfil_nome;
  if v_perfil_id is null then raise exception 'Cargo inválido'; end if;

  insert into gestao360.usuarios (auth_user_id, tenant_id, nome, email, perfil_id, secretaria_id, status)
  values (auth.uid(), v_tenant_id, p_nome, (select email from auth.users where id = auth.uid()), v_perfil_id, p_secretaria_id, 'pendente');
end;
$$;
grant execute on function gestao360.autocadastrar_usuario(text, text, uuid) to authenticated;

create or replace function gestao360.aprovar_usuario(p_usuario_id uuid)
returns void
language plpgsql security definer set search_path = gestao360, public
as $$
begin
  if not exists (
    select 1 from gestao360.usuarios u join gestao360.perfis p on p.id = u.perfil_id
    where u.auth_user_id = auth.uid() and p.nome = 'admin_master'
  ) then
    raise exception 'Apenas o Administrador Master pode aprovar usuários';
  end if;
  update gestao360.usuarios set status = 'ativo' where id = p_usuario_id;
end;
$$;
grant execute on function gestao360.aprovar_usuario(uuid) to authenticated;

create or replace function gestao360.admin_criar_usuario(p_auth_user_id uuid, p_nome text, p_perfil_nome text, p_secretaria_id uuid)
returns void
language plpgsql security definer set search_path = gestao360, public
as $$
declare
  v_perfil_id uuid;
  v_tenant_id uuid;
begin
  if not exists (
    select 1 from gestao360.usuarios u join gestao360.perfis p on p.id = u.perfil_id
    where u.auth_user_id = auth.uid() and p.nome = 'admin_master'
  ) then
    raise exception 'Apenas o Administrador Master pode cadastrar usuários diretamente';
  end if;

  select id into v_tenant_id from gestao360.tenants order by criado_em asc limit 1;
  select id into v_perfil_id from gestao360.perfis where nome = p_perfil_nome;
  if v_perfil_id is null then raise exception 'Cargo inválido'; end if;

  insert into gestao360.usuarios (auth_user_id, tenant_id, nome, email, perfil_id, secretaria_id, status)
  values (p_auth_user_id, v_tenant_id, p_nome, (select email from auth.users where id = p_auth_user_id), v_perfil_id, p_secretaria_id, 'ativo');
end;
$$;
grant execute on function gestao360.admin_criar_usuario(uuid, text, text, uuid) to authenticated;

-- ============================================================
-- Hook de claims customizadas do Auth
-- (precisa ser ativado manualmente no Dashboard — ver PASSO MANUAL abaixo)
-- ============================================================

create or replace function gestao360.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql stable security definer set search_path = gestao360, public
as $$
declare
  claims jsonb;
  usuario_record gestao360.usuarios%rowtype;
  perfil_nome text;
begin
  select * into usuario_record from gestao360.usuarios u where u.auth_user_id = (event->>'user_id')::uuid limit 1;
  claims := event->'claims';

  if usuario_record.id is not null then
    select nome into perfil_nome from gestao360.perfis where id = usuario_record.perfil_id;
    claims := jsonb_set(claims, '{perfil}', to_jsonb(coalesce(perfil_nome, '')));
    claims := jsonb_set(claims, '{tenant_id}', to_jsonb(usuario_record.tenant_id::text));
    claims := jsonb_set(claims, '{secretaria_id}', to_jsonb(coalesce(usuario_record.secretaria_id::text, '')));
    claims := jsonb_set(claims, '{status}', to_jsonb(usuario_record.status));
  end if;

  event := jsonb_set(event, '{claims}', claims);
  return event;
end;
$$;

grant usage on schema gestao360 to supabase_auth_admin;
grant execute on function gestao360.custom_access_token_hook(jsonb) to supabase_auth_admin;
revoke execute on function gestao360.custom_access_token_hook(jsonb) from authenticated, anon, public;

-- ============================================================
-- Storage: fotos/vídeos de eventos
-- ============================================================

insert into storage.buckets (id, name, public) values ('evento-midias', 'evento-midias', true) on conflict (id) do nothing;

create policy evento_midias_storage_select on storage.objects for select to anon, authenticated using (bucket_id = 'evento-midias');
create policy evento_midias_storage_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'evento-midias' and gestao360.jwt_perfil() in ('admin_master','prefeito','secretario','diretor','coordenador'));

-- ============================================================
-- Seeds (estrutura de referência — sem dados reais)
-- ============================================================

insert into gestao360.tenants (id, nome) values ('00000000-0000-0000-0000-000000000001','Tenant Demo');

insert into gestao360.perfis (nome, descricao) values
  ('admin_master','Administrador Master — acesso total'),
  ('prefeito','Prefeito(a)'),
  ('vice_prefeito','Vice-Prefeito(a)'),
  ('comunicacao','Comunicação'),
  ('secretario','Secretário(a)'),
  ('diretor','Diretor(a)'),
  ('coordenador','Coordenador(a)'),
  ('controladoria','Controladoria'),
  ('servidor','Servidor(a)');

insert into gestao360.secretarias (tenant_id, nome) values
  ('00000000-0000-0000-0000-000000000001','Gabinete'),
  ('00000000-0000-0000-0000-000000000001','Administração'),
  ('00000000-0000-0000-0000-000000000001','Finanças'),
  ('00000000-0000-0000-0000-000000000001','Educação'),
  ('00000000-0000-0000-0000-000000000001','Saúde'),
  ('00000000-0000-0000-0000-000000000001','Agricultura'),
  ('00000000-0000-0000-0000-000000000001','Indústria e Comércio'),
  ('00000000-0000-0000-0000-000000000001','Turismo'),
  ('00000000-0000-0000-0000-000000000001','Cultura'),
  ('00000000-0000-0000-0000-000000000001','Esporte'),
  ('00000000-0000-0000-0000-000000000001','Meio Ambiente'),
  ('00000000-0000-0000-0000-000000000001','Assistência Social'),
  ('00000000-0000-0000-0000-000000000001','Obras e Serviços Públicos'),
  ('00000000-0000-0000-0000-000000000001','Planejamento'),
  ('00000000-0000-0000-0000-000000000001','Inovação e Tecnologia'),
  ('00000000-0000-0000-0000-000000000001','Defesa Civil');

insert into gestao360.categorias (nome) values
  ('Pavimentação'),('Reformas'),('Construção'),('Saúde'),('Educação'),('Saneamento'),
  ('Iluminação Pública'),('Habitação'),('Mobilidade Urbana'),('Meio Ambiente'),
  ('Cultura e Lazer'),('Esporte'),('Assistência Social'),('Segurança Pública'),
  ('Turismo'),('Agricultura'),('Tecnologia'),('Eventos'),('Administração Geral');

insert into gestao360.permissoes (modulo, chave, descricao) values
  ('acoes','acoes.ver','Ver ações cadastradas'),
  ('acoes','acoes.criar','Cadastrar novas ações'),
  ('acoes','acoes.editar','Editar ações existentes'),
  ('recursos','recursos.ver','Ver captação de recursos'),
  ('recursos','recursos.criar','Cadastrar oportunidades de recursos'),
  ('usuarios','usuarios.gerenciar','Aprovar e gerenciar usuários'),
  ('secretarias','secretarias.gerenciar','Cadastrar e editar secretarias'),
  ('promessas','promessas.gerenciar','Gerenciar plano de governo'),
  ('avaliacoes','avaliacoes.ver','Ver avaliações e manifestações internas');

insert into gestao360.perfil_permissoes (perfil_id, permissao_id, concedida)
select p.id, perm.id, true
from gestao360.perfis p
cross join gestao360.permissoes perm
where p.nome = 'admin_master';

insert into gestao360.perfil_permissoes (perfil_id, permissao_id, concedida)
select p.id, perm.id, true
from gestao360.perfis p
cross join gestao360.permissoes perm
where p.nome in ('prefeito','vice_prefeito') and perm.chave in ('acoes.ver','recursos.ver','promessas.gerenciar','avaliacoes.ver');

insert into gestao360.perfil_permissoes (perfil_id, permissao_id, concedida)
select p.id, perm.id, true
from gestao360.perfis p
cross join gestao360.permissoes perm
where p.nome in ('secretario','diretor','coordenador') and perm.chave in ('acoes.ver','acoes.criar','acoes.editar','recursos.ver','recursos.criar');

insert into gestao360.perfil_permissoes (perfil_id, permissao_id, concedida)
select p.id, perm.id, true
from gestao360.perfis p
cross join gestao360.permissoes perm
where p.nome = 'servidor' and perm.chave in ('acoes.ver','acoes.criar');

insert into gestao360.perfil_permissoes (perfil_id, permissao_id, concedida)
select p.id, perm.id, true
from gestao360.perfis p
cross join gestao360.permissoes perm
where p.nome = 'controladoria' and perm.chave in ('acoes.ver','recursos.ver','avaliacoes.ver');

insert into gestao360.perfil_permissoes (perfil_id, permissao_id, concedida)
select p.id, perm.id, true
from gestao360.perfis p
cross join gestao360.permissoes perm
where p.nome = 'comunicacao' and perm.chave in ('acoes.ver');

-- ============================================================
-- PASSO MANUAL 1 — ativar o hook de claims
-- ============================================================
-- No Dashboard do projeto NOVO: Authentication → Hooks → Custom Access
-- Token → escolha a função "gestao360.custom_access_token_hook" → Save.
-- Sem isso, o token de login não vai trazer perfil/tenant_id/secretaria_id
-- e as políticas de RLS acima não vão liberar nada.

-- ============================================================
-- PASSO MANUAL 2 — criar o primeiro Admin Master
-- ============================================================
-- 1. Abra conecta-gestao-cadastro.html (já apontando pro projeto novo) e
--    crie uma conta com o cargo "Servidor" (qualquer um da lista serve,
--    isso vai ser sobrescrito no passo 3).
-- 2. Volte aqui no SQL Editor e rode (troque o e-mail pelo que você usou):
--
--   update gestao360.usuarios
--   set perfil_id = (select id from gestao360.perfis where nome = 'admin_master'),
--       status = 'ativo'
--   where email = 'SEU-EMAIL-AQUI@exemplo.com';
--
-- 3. Faça logout/login de novo no Painel Admin — agora sua conta é
--    Admin Master e pode aprovar os próximos usuários pela própria tela.
