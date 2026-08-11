# Estado Atual do Projeto

Retrato honesto do que **realmente funciona com dados reais** vs. **protótipo visual** vs. **não existe ainda**. Atualizado no fim da sessão de setup inicial (04–05/ago/2026).

---

## ✅ FEITO E FUNCIONANDO DE VERDADE (com dados reais no Supabase)

### Infraestrutura
- Banco Supabase completo com **25 tabelas** no schema `gestao360` isolado
- **RLS por tenant + escopo por secretaria** ativo em todas as tabelas
- Site publicado no ar: https://conectagestao360.vercel.app
- Sistema **multi-tenant** preparado (hoje só o tenant demo está em uso)
- Hook JWT do Supabase Auth **ativo**, injetando `perfil`, `tenant_id`, `secretaria_id` no token
- **pg_cron** rodando todo dia às 08:00 UTC (job de alertas de prazo)

### Login e usuários
- Login real via Supabase Auth (não é mockado)
- Tela pública de cadastro (`conecta-gestao-cadastro.html`) — qualquer servidor cria a própria conta
- Tela de vincular usuário no Painel Admin — Admin Master aprova e define cargo/secretaria sem precisar mexer no banco
- **9 perfis** com permissões catalogadas no banco (Admin Master, Prefeito, Vice-Prefeito, Comunicação, Secretário, Diretor, Coordenador, Controladoria, Servidor)
- Conta admin já criada: `gabrielfotossouza05@gmail.com` (perfil `admin_master`, tenant demo)

### Portal Público (`index.html`)
- Página inicial com KPIs reais puxados do banco
- Notícias, Secretarias, Obras (com **filtro funcional** por Ano/Secretaria/Categoria/Status/Bairro)
- Linha do Tempo, Indicadores
- **Mapa** com 9 categorias (Escolas, UBS, Praças, Obras, Estradas, Turismo, Pontes, Iluminação, Agricultura)
- **Plano de Governo** com % de cumprimento em tempo real
- Prestação de Contas com dados reais
- **Sua Voz** gravando manifestações reais no banco — com foto (até 2MB) + localização GPS
- **Avaliação da Gestão** gravando notas reais (confidencial, só Prefeito/Admin veem)

### Painel Administrativo (`conecta-gestao-painel-admin.html`)
- Dashboard com KPIs reais das ações no escopo do usuário
- **Cadastro de Ações** gravando no banco de verdade (todos os campos da especificação: título, descrição, ano, data, secretaria, categoria, subcategoria, objetivo, local, bairro, GPS, valor, origem, convênio, processo, empresa, status, beneficiados, observações)
- **Captação de Recursos** com funil completo (Prospectando → Em elaboração → Submetido → Aprovado/Reprovado → Em execução → Concluído)
- **Alertas automáticos de prazo** (15/7/1 dias antes) rodando todo dia às 8h via pg_cron
- Sino de notificações na sidebar (com contador de não lidas)
- **Plano de Governo** (cadastrar promessas, marcar cumprimento via dropdown)
- **Importar CSV do Paraná** (Portal da Transparência estadual) via PapaParse
- **Secretarias** (listar as 16 e cadastrar novas)
- **Usuários e Permissões** (matriz de permissões × perfis + vincular usuários)

### Créditos
- "Desenvolvido por **Gabriel Oliveira** · Tecnologia e Manutenção" em todas as 7 telas
- No Portal Público: integrado ao rodapé
- Nas outras 6 telas: badge fixo no canto inferior direito

---

## ⚠️ PROTÓTIPO VISUAL PRONTO (mas dados são fixos, precisa conectar ao banco)

| Módulo | Arquivo | O que falta |
|---|---|---|
| **Dashboard do Prefeito** | `conecta-gestao-dashboard-prefeito.html` | Conectar os 12 indicadores, mapa, gráficos ao banco (foi iniciado, mas não finalizado no arquivo entregue) |
| **Painel Interno das Avaliações** | `conecta-gestao-avaliacoes.html` | Ligar aos dados reais que já existem em `gestao360.avaliacoes` e `gestao360.manifestacoes` |
| **Módulo de IA** | `conecta-gestao-ia.html` | Trocar textos-modelo estáticos por chamadas à Claude API |
| **Relatórios** | `conecta-gestao-relatorios.html` | Botão "Exportar PDF/Excel/Word" é só visual — não gera arquivo real |
| **Fluxo de Aprovação** | (sem tela ainda) | Estrutura no banco existe (`etapa_fluxo`, tabela `aprovacoes`), falta UI pra mover ação entre etapas |

---

## ❌ NÃO EXISTE AINDA

- **Livro da Gestão** — só o botão no protótipo de IA, sem geração real
- **Galeria** — só grade estática, não puxa fotos reais das ações
- **Backup manual/restauração** — Supabase faz backup de infra, mas não há botão no sistema
- **Auditoria e Logs** — tabela `logs_auditoria` existe no banco, mas nada grava nela e não há tela de consulta
- **Aplicativo Mobile** — não construído (requer compilação nativa e publicação em loja)
- **Descoberta automática de editais federais/estaduais** — pesquisado e descartado (APIs frágeis/incompletas); a solução escolhida foi importação manual por CSV

---

## Módulos que estão parcialmente completos

- **Consulta da população**: filtros por Ano/Secretaria/Categoria/Status/Bairro **funcionam**; filtros por Mês e Subcategoria não existem ainda.
- **Transparência**: mostra valor investido e origem do recurso; **não mostra** fotos/vídeos/antes-depois/documentos por ação (a estrutura existe no banco em `acao_midias` e `acao_anexos`, falta UI).
- **Avaliação da Gestão**: avaliação **geral** funciona; avaliação **por secretaria individual** não foi construída ainda.

---

## Bugs conhecidos que ficaram resolvidos nesta sessão

1. ✅ RLS bloqueava o próprio hook (referência circular) — corrigido com policies `hook_read_usuarios`/`hook_read_perfis` para `supabase_auth_admin`
2. ✅ Bug do PL/pgSQL: `record IS NOT NULL` não é confiável — reescrito com variáveis simples usando `FOUND`
3. ✅ Faltavam grants no schema `gestao360` para `anon`/`authenticated`
4. ✅ Notificações vazavam entre usuários — policy `dono_notificacoes` corrigida usando `current_usuario_id()`
5. ✅ Filtro de obras no Portal Público não filtrava — corrigido, agora funciona
6. ✅ Mapa faltavam 3 categorias (Pontes, Iluminação, Agricultura) — adicionadas
7. ✅ "Sua Voz" sem campos de foto/localização — adicionados
