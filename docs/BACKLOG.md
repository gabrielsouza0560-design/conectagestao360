# Backlog

Lista priorizada do que ainda precisa ser construído, do mais rápido pro mais trabalhoso.
Cada item tem uma estimativa relativa de esforço.

---

## 🟢 Rápido (1 sessão curta cada)

### 1. Dashboard do Prefeito conectado ao banco
- **Arquivo:** `conecta-gestao-dashboard-prefeito.html`
- **Estado:** trabalho começou nesta sessão — login gate e sbGet foram adicionados, mas o `populate()` novo pode não ter sido totalmente incorporado no arquivo final entregue
- **O que fazer:** confirmar que a tela substitui os arrays hardcoded (`KPIS`, `MONTHS`, `DONUT`, `SEC_INVEST`, `RANKING`) por consultas às tabelas `acoes`, `indicadores`, `mapa_pontos`, `avaliacoes`
- **Restrição de acesso:** Admin Master, Prefeito, Vice-Prefeito, Controladoria

### 2. Painel Interno das Avaliações conectado ao banco
- **Arquivo:** `conecta-gestao-avaliacoes.html`
- **O que fazer:** ler `gestao360.avaliacoes` (nota média, contagens por tipo) e `gestao360.manifestacoes` (contagens por sugestão/elogio/crítica/reclamação, ranking, mapa por bairro)
- **Restrição de acesso:** só Prefeito e Admin Master (RLS já enforça isso no banco)

### 3. Categorias faltando do Portal Público
- Filtros de obras por **Mês** e **Subcategoria**
- Mostrar fotos/vídeos/antes-depois/documentos por ação (estrutura já existe em `acao_midias`/`acao_anexos`)

### 4. Avaliação por secretaria individual no Portal Público
- Hoje só há avaliação geral; adicionar seletor de secretaria e gravar `secretaria_id` no insert de `avaliacoes`

---

## 🟡 Médio (2-4 sessões)

### 5. Tela de Fluxo de Aprovação
- **Estrutura no banco:** já existe (`etapa_fluxo`, tabela `aprovacoes`)
- **Falta:** UI no Painel Admin com fila de "ações aguardando minha aprovação", botões "Aprovar" / "Reprovar" / "Devolver" — cada perfil vê só o que compete a ele (Diretor vê o que veio do Servidor, Secretário vê o que veio do Diretor, etc.)
- **Fluxo:** Servidor → Diretor → Secretário → Comunicação → Prefeito → Portal Público

### 6. Galeria com fotos reais
- Hoje: grade estática
- **Falta:** puxar fotos reais das ações via `gestao360.acao_midias`
- **Requer:** upload de fotos (Supabase Storage) na tela de Cadastro de Ações

### 7. Auditoria e Logs
- **Estrutura no banco:** tabela `logs_auditoria` existe mas nunca é preenchida
- **Falta:** triggers ou hooks nas tabelas críticas (`usuarios`, `perfis`, `acoes`, `publicacoes`) que gravem ali, + tela de consulta para Admin Master (com filtros por usuário, entidade, período)

### 8. Suporte a upload de fotos/vídeos/documentos nas ações
- Adicionar upload no formulário de Cadastro de Ações usando Supabase Storage
- Bucket público para mídias que virão no Portal Público, bucket privado para documentos internos

---

## 🔴 Grande (5+ sessões cada)

### 9. Relatórios com exportação real (PDF/Excel/Word)
- Hoje o botão só simula
- **Bibliotecas viáveis:** jsPDF (PDF), SheetJS (Excel), docx (Word) — tudo client-side
- **Relatórios definidos:** Mensal, Trimestral, Semestral, Anual, Final de Gestão

### 10. Integração de IA de verdade
- Hoje: textos-modelo estáticos
- **Falta:** integrar com Claude API para gerar
  - Notícias, posts (Facebook/Instagram/WhatsApp), discursos
  - Prestação de contas, relatórios mensal/anual
  - Livro da Gestão, resumos automáticos
- **Requer:** proxy backend (Edge Function do Supabase) para não expor a chave da API no frontend

### 11. Livro da Gestão
- Ao final do mandato, compilar automaticamente PDF completo contendo: todas as ações, fotos, gráficos, indicadores, linha do tempo, investimentos, resultados, secretarias, prestação de contas
- Depende dos itens 9 e 10 estarem prontos

### 12. Aplicativo Mobile (Android + iOS)
- **NÃO É POSSÍVEL construir dentro do Claude Code ou do ambiente atual** — requer:
  - Compilação nativa (React Native, Flutter, ou Kotlin/Swift)
  - Contas de desenvolvedor Apple ($99/ano) e Google Play ($25 único)
  - Ambiente de build com Xcode (macOS obrigatório) e Android Studio
- **Alternativa realista:** transformar o Portal Público em PWA (Progressive Web App) — instalável no celular direto pelo navegador, sem lojas. É a mesma UX de app para 90% dos casos e é factível de construir aqui.

### 13. Backup manual e restauração
- Supabase já faz backup de infraestrutura automático
- **Falta:** botão no Painel Admin que exporta o schema `gestao360` inteiro em SQL/JSON pro Admin Master baixar, e opção de restauração a partir de arquivo enviado

### 14. Descoberta automática de editais federais/estaduais
- **Já foi pesquisado e descartado** nesta sessão — não existe API estável
- Portal da Transparência (federal) mostra convênios *já executados*, não abertos
- Portal do Paraná gera CSV sob demanda (impossível automatizar sem scraping frágil)
- **Solução escolhida:** manter importação manual por CSV (já implementada)

---

## Notas gerais

- **Não vou reescrever nada que já foi entregue** sem ser pedido — os módulos existentes que funcionam com dados reais devem ser preservados
- **Toda mudança no banco vira uma migration** em `supabase/migrations/` (nome padrão: `AAAAMMDDHHMMSS_gestao360_descricao.sql`)
- **Todos os textos são em português brasileiro**
- **Design:** azul royal (#2563EB), Inter, glassmorphism, inspirado em Stripe/Vercel/Linear — manter esse padrão em qualquer tela nova
