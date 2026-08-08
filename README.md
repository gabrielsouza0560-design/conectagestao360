# Conecta Gestão

Plataforma SaaS multi-tenant para gestão pública municipal.
Combina painel administrativo interno com portal público de transparência.

**Nome do projeto:** Conecta Gestão (antes chamado internamente de Gestão 360 Brasil)
**Ambiente:** Netlify (frontend estático) + Supabase (backend)
**Site em produção:** https://conectagestao360.netlify.app

## Stack

- **Frontend:** HTML/CSS/JS puro (sem framework), Inter font, glassmorphism azul royal
- **Backend:** Supabase (Postgres + Auth + RLS)
- **Deploy:** Netlify (drag-and-drop ou `netlify deploy --prod --dir=.`)

## Estrutura de arquivos

- `index.html` — Portal Público (transparência, sem login)
- `conecta-gestao-painel-admin.html` — Painel Administrativo (login real)
- `conecta-gestao-cadastro.html` — Auto-cadastro de servidores
- `conecta-gestao-dashboard-prefeito.html` — Dashboard executivo (Prefeito/Admin)
- `conecta-gestao-ia.html` — Módulo de Inteligência Artificial (protótipo)
- `conecta-gestao-avaliacoes.html` — Painel Interno das Avaliações (Prefeito/Admin)
- `conecta-gestao-relatorios.html` — Central de Relatórios (protótipo)
- `supabase/migrations/` — 23 migrations do schema `gestao360`

## Credenciais Supabase (chaves públicas, não são secretas)

- URL: `https://fclpcdtnmlpjfgovubra.supabase.co`
- Anon key: embutida em cada HTML (safe para client-side)
- Projeto: `ray-modas` (schema isolado `gestao360`)
- Tenant demo: `00000000-0000-0000-0000-000000000001`

## Login de teste (Admin Master)

- E-mail: `gabrielfotossouza05@gmail.com`
- Senha: definida no Supabase Auth (não versionada)

## Deploy

```bash
# Opção 1 — CLI (recomendado)
netlify deploy --prod --dir=.

# Opção 2 — drag-and-drop
# https://app.netlify.com/projects/conectagestao360
```

Site atual: `conectagestao360.netlify.app`

## Migrations do banco

Todas as 23 migrations que compõem o schema `gestao360` estão em `supabase/migrations/`.
Nomes começam com `20260804*_gestao360_*`. Para aplicar em outro projeto Supabase:

```bash
supabase link --project-ref <SEU_PROJECT_REF>
supabase db push
```

## Estado atual (o que está feito de verdade)

Veja `docs/ESTADO_ATUAL.md` para o retrato honesto do que funciona vs. o que é só protótipo.

## Backlog

Veja `docs/BACKLOG.md` para o que ainda precisa ser construído.
