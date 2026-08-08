# Migrations

O banco Supabase já tem TODAS as 23 migrations aplicadas em produção.
Para obter os arquivos SQL localmente, execute UMA das opções:

## Opção 1 — Via Supabase CLI (recomendado)

```bash
# 1. Instale a CLI (npm)
npm install -g supabase

# 2. Faça login
supabase login

# 3. Linke ao projeto
supabase link --project-ref fclpcdtnmlpjfgovubra

# 4. Puxe TODAS as migrations existentes para esta pasta
supabase db pull
```

## Opção 2 — Peça ao Claude Code

Se você está usando Claude Code com o Supabase MCP conectado, basta pedir:

> "Puxe todas as migrations que começam com 'gestao360' do projeto Supabase fclpcdtnmlpjfgovubra e salve como arquivos individuais em supabase/migrations/"

O Claude Code vai buscar via MCP e criar cada arquivo `.sql` aqui.

## Lista das 23 migrations existentes

Todas com prefixo `20260804*_gestao360_*`:

1. schema_and_identity — tabelas núcleo (tenants, perfis, usuarios, secretarias)
2. acoes_e_fluxo — ações de governo, aprovações, publicações
3. participacao_e_sistema — manifestações, avaliações, indicadores, mapa
4. rls_policies — políticas de segurança por tenant + escopo
5. seed_dados_referencia — 16 secretarias, 19 categorias, 9 perfis
6. rls_tabelas_referencia — RLS de perfis/permissões
7. auth_custom_claims_hook — hook JWT (perfil/tenant no token)
8. acesso_publico_portal — leitura pública sem login
9. seed_acoes_demo — 5 ações + indicadores + publicações demo
10. vincular_primeiro_usuario — vincula gabrielfotossouza05@gmail.com como admin_master
11. grants_anon_authenticated — grants base de acesso
12. fix_hook_rls_bypass — correção do hook + RLS circular
13. fix_hook_record_bug — correção do bug do PL/pgSQL
14. plano_de_governo — tabela promessas_campanha + policies
15. captacao_recursos — funil de recursos (Federal/Estadual)
16. alertas_prazo_recursos — pg_cron diário para notificações
17. fix_notificacoes_privacidade — RLS por dono da notificação
18. recursos_referencia_estadual — importação CSV do Paraná
19. vincular_usuario_automatico — RPC para admin vincular via UI
20. permissoes_admin_master_completo — 47 permissões oficiais
21. permissoes_prefeito_vice — permissões Prefeito + Vice
22. permissoes_comunicacao_secretario_diretor_servidor — resto dos perfis
23. indicadores_demo_extras — indicadores para dashboard demo
