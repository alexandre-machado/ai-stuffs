# Setup WSL — Otimização de Consumo de Tokens para AI Coding

> Guia completo para configurar um ambiente local no WSL focado em reduzir 60-90% do consumo de tokens com Claude Code, Copilot e Gemini CLI.

---

## Visão Geral da Arquitetura

```
┌────────────────────────────────────────────────────────┐
│                  SEU TERMINAL WSL                      │
│                                                        │
│  ┌──────────┐   ┌───────────┐   ┌───────────────────┐  │
│  │  Claude  │   │  Copilot  │   │     Gemini CLI    │  │
│  │   Code   │   │  (VSCode) │   │                   │  │
│  └────┬─────┘   └─────┬─────┘   └────────┬──────────┘  │
│       │               │                  │             │
│  ┌────▼───────────────▼──────────────────▼──────────┐  │
│  │              CAMADA 1: RTK (Rust)                │  │
│  │   Intercepta comandos CLI → output comprimido    │  │
│  │   git, cat, grep, test → 60-90% menos tokens     │  │
│  └──────────────────────┬───────────────────────────┘  │
│                         │                              │
│  ┌──────────────────────▼───────────────────────────┐  │
│  │            CAMADA 2: HEADROOM (Python)           │  │
│  │   Proxy transparente → comprime contexto LLM     │  │
│  │  JSON, RAG, logs, código → 70-95% menos tokens   │  │
│  └──────────────────────┬───────────────────────────┘  │
│                         │                              │
│  ┌──────────────────────▼───────────────────────────┐  │
│  │          CAMADA 3: MEMSTACK (Markdown)           │  │
│  │   Memória persistente + handoff entre sessões    │  │
│  │  SQLite + vector search → contexto inteligente   │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │        MONITORAMENTO: ccusage + cmonitor         │  │
│  │   Tracking em tempo real de tokens e custos      │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

**Por que 3 camadas?** RTK e Headroom são complementares por design: RTK reescreve comandos CLI (git, cat, grep) para gerar output enxuto *antes* de chegar ao LLM. Headroom comprime tudo o que sobra (JSON, código, histórico de conversa) *depois* que o output é gerado. Juntos cobrem praticamente 100% do contexto que um agente consome.

---

## Pré-requisitos

```bash
# WSL2 com Ubuntu 24.04+
wsl --install -d Ubuntu-24.04

# Dentro do WSL:
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git curl python3 python3-pip python3-venv

# Node.js (LTS via nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install --lts

# Rust (necessário para rtk via cargo)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

---

## Notas para reruns e fallback

- O bootstrap script fica em `dont-throw-away-my-tokens/need-more-tokens.sh`.
- Se o shell não tiver um rc claro, o script cai em `~/.profile` para manter as mudanças idempotentes.
- Se o Python do sistema estiver gerenciado, o script avisa e usa `--break-system-packages`; prefira venv ou conda quando quiser isolamento mais rígido.

## Camada 1 — RTK (Rust Token Killer)

**O que faz:** Proxy CLI que intercepta comandos do shell e retorna output comprimido. Um binário Rust, <10ms de overhead, 100+ comandos suportados.

**Economia:** ~80% de redução numa sessão típica de 30 min (118k → 24k tokens).

### Instalação

```bash
# Opção 1: Script rápido (recomendado)
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Opção 2: Via Cargo
cargo install --git https://github.com/rtk-ai/rtk

# Verificar
rtk --version
```

### Configuração por Agente

```bash
# Claude Code (hook PreToolUse — transparente)
rtk init -g

# GitHub Copilot (VS Code + CLI)
rtk init -g --copilot

# Gemini CLI
rtk init -g --gemini

# Codex (OpenAI)
rtk init -g --codex

# Cursor / Windsurf / Cline
rtk init -g --agent cursor
rtk init --agent windsurf
rtk init --agent cline
```

> **Importante:** O hook do RTK só atua em chamadas Bash. Ferramentas built-in do Claude Code (Read, Grep, Glob) não passam pelo hook. Para máxima economia, prefira comandos shell (`cat`, `rg`, `find`) ou chame `rtk read`, `rtk grep` diretamente.

### Configuração Avançada

```bash
# Criar config personalizado
mkdir -p ~/.config/rtk
cat > ~/.config/rtk/config.toml << 'EOF'
[hooks]
# Excluir comandos que precisam de output completo
exclude_commands = ["curl", "playwright"]

[tee]
enabled = true          # Salva output completo em caso de falha
mode = "failures"       # "failures", "always", ou "never"
max_files = 20
EOF
```

### Verificar Economia

```bash
rtk gain              # Resumo de economia
rtk gain --graph      # Gráfico ASCII (últimos 30 dias)
rtk gain --daily      # Breakdown diário
rtk discover          # Encontra oportunidades de economia perdidas
```

---

## Camada 2 — Headroom (Context Compression)

**O que faz:** Proxy entre sua aplicação e o LLM. Intercepta requests, comprime o contexto com múltiplos algoritmos (SmartCrusher para JSON, CodeCompressor para código, Kompress para texto), e encaminha o prompt otimizado. Compressão reversível — o LLM pode recuperar o original se precisar.

**Economia:** 47-92% dependendo do tipo de conteúdo.

### Instalação

```bash
# Core + proxy + MCP (recomendado)
pip install "headroom-ai[all]" --break-system-packages

# Ou em venv dedicado (mais limpo)
python3 -m venv ~/.headroom-env
source ~/.headroom-env/bin/activate
pip install "headroom-ai[all]"
```

### Modo Proxy (zero mudanças de código)

```bash
# Iniciar proxy
headroom proxy --port 8787

# Em outro terminal, apontar agentes para o proxy:
export ANTHROPIC_BASE_URL=http://localhost:8787
export OPENAI_BASE_URL=http://localhost:8787/v1
```

### Modo Wrap (mais simples para coding agents)

```bash
headroom wrap claude    # Inicia proxy + lança Claude Code
headroom wrap codex     # Inicia proxy + lança Codex
headroom wrap aider     # Inicia proxy + lança Aider
headroom wrap cursor    # Inicia proxy + imprime config do Cursor
```

### MCP Tools (Claude Code / Cursor)

```bash
headroom mcp install && claude
# Disponibiliza: headroom_compress, headroom_retrieve, headroom_stats
```

### Failure Learning (opcional, muito útil)

```bash
headroom learn              # Analisa sessões passadas, mostra recomendações
headroom learn --apply      # Escreve aprendizados em CLAUDE.md e MEMORY.md
headroom learn --all --apply  # Aprende de todos os projetos
```

### Tornar Permanente

```bash
# Adicionar ao .bashrc
cat >> ~/.bashrc << 'EOF'

# Headroom proxy
export ANTHROPIC_BASE_URL=http://127.0.0.1:8787
EOF
source ~/.bashrc
```

---

## Camada 3 — MemStack (Memória Persistente)

**O que faz:** Framework de skills em markdown para Claude Code com memória SQLite, busca semântica via LanceDB, hooks determinísticos, e handoff entre sessões. Evita que você re-explique contexto toda sessão (o maior desperdício de tokens).

### Instalação

```bash
cd ~/projects
git clone https://github.com/cwinvestments/memstack.git
cd memstack

# Configurar
cp config.json config.local.json
# Editar config.local.json com seus caminhos de projeto

# Inicializar banco
python3 db/memstack-db.py init

# Busca semântica (opcional mas recomendado)
pip install lancedb sentence-transformers --break-system-packages
python3 skills/echo/index-sessions.py
```

### Instalar em Projetos

```bash
# Via symlink (atualizações propagam automaticamente)
ln -s ~/projects/memstack/.claude ~/projects/seu-projeto/.claude
```

### Comandos Úteis

```bash
# Buscar na memória
# Dentro do Claude Code: /memstack-search <query>

# Ver status do Headroom
# Dentro do Claude Code: /memstack-headroom

# Pesquisar no banco
python3 db/memstack-db.py search "autenticação"
python3 db/memstack-db.py get-sessions meu-projeto
python3 db/memstack-db.py stats
```

---

## Monitoramento — ccusage primeiro, Claude Monitor como complemento

Depois de instalar o setup, comece pelo `ccusage` para confirmar consumo e economia de forma objetiva. Ele deve ser o caminho padrão de monitoramento (MON-01), porque permite verificar histórico diário, mensal e por sessão sem depender de dashboard ativo.

Fluxo recomendado (ccusage-first):

```bash
# baseline diário/mensal/sessão
npx ccusage@latest daily
npx ccusage@latest monthly
npx ccusage@latest session

# visão ao vivo quando precisar acompanhar uma janela em andamento
npx ccusage@latest blocks --live
```

Quando você já tiver baseline e quiser observar burn rate em tempo real durante uma sessão específica, use Claude Monitor como opção secundária (complementar, não substituta):

```bash
# Instalar (opcional)
pip install claude-monitor --break-system-packages
# Ou: uv tool install claude-monitor

# Monitor em tempo real
cmonitor
```

---

## Configurações do Ambiente (Claude Code)

### settings.json (~/.claude/settings.json)

```json
{
  "model": "sonnet",
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku"
  }
}
```

**Justificativa:**
- Sonnet como padrão resolve ~80% das tarefas. Mude para Opus com `/model opus` só para raciocínio complexo (~60% de redução de custo).
- `MAX_THINKING_TOKENS` em 10000 corta ~70% dos tokens "escondidos" de extended thinking.
- Subagentes em Haiku são ~80% mais baratos e suficientes para exploração, leitura de arquivos e testes.

### .claudeignore (raiz do projeto)

```gitignore
node_modules/
dist/
build/
*.lock
__pycache__/
.git/
*.db
*.sqlite
.next/
coverage/
*.log
```

### CLAUDE.md enxuto

Mantenha o CLAUDE.md **curto** (< 200 linhas). Ele é lido a cada sessão — cada palavra custa tokens toda vez. Remova tudo que é descritivo ou aspiracional. Se não muda como o Claude deve se comportar, não pertence ali.

---

## Quando pular otimização agressiva (regra prática)

Use as ferramentas de otimização por padrão, mas pule compressão agressiva quando o contexto exigir fidelidade total de saída. Regra simples: se você precisa de saída completa para tomar decisão segura, não comprima nessa etapa.

Situações típicas para pular otimização:

- Comandos que exigem **full output** para diagnóstico confiável (logs longos, diffs extensos, traces completos).
- Operações com **alto risco de side effects** (deploy, migração, comandos destrutivos, alterações irreversíveis).
- Troubleshooting em que qualquer perda de detalhe pode esconder a causa raiz.

Depois de concluir a etapa crítica, volte ao fluxo otimizado normalmente para recuperar economia de tokens.

---

## Hábitos de Sessão (Economia Comportamental)

Essas práticas complementam as ferramentas e podem economizar tanto quanto elas:

1. **`/clear` entre tarefas** — Contexto antigo desperdiça tokens em cada mensagem subsequente.
2. **`/compact` quando a conversa cresce** — Comprima antes de perder contexto. Use: `/compact Foque em exemplos de código e uso da API`.
3. **Shift+Tab ×2 → Plan Mode** — Antes de operações caras, entre no modo de planejamento. Com `opusplan`, usa Opus para planejar e Sonnet para implementar.
4. **Aponte arquivos, não peça busca** — `"Corrija o bug em src/auth/login.ts linha 42"` é muito mais barato que `"olhe o codebase e descubra o problema"`.
5. **Não repita contexto** — Se Claude já sabe que você usa TypeScript strict, não repita isso na mensagem 9.
6. **Audite MCPs ativos** — Cada MCP carregado adiciona tokens ao system prompt em toda mensagem. Desative os que não está usando.
7. **Saída de agentes para disco** — Configure agentes de pesquisa para escrever resultados em arquivo ao invés de retornar no contexto.

---

## Script de Bootstrap Completo

```bash
#!/bin/bash
# wsl-token-setup.sh — Roda dentro do WSL

set -e

echo "=== [1/6] Pré-requisitos ==="
sudo apt update && sudo apt install -y build-essential git curl python3 python3-pip python3-venv

# Node.js
if ! command -v node &> /dev/null; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

# Rust
if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
fi

echo "=== [2/6] RTK ==="
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
rtk init -g                    # Claude Code
rtk init -g --copilot          # Copilot
rtk init -g --gemini           # Gemini CLI

echo "=== [3/6] Headroom ==="
python3 -m venv ~/.headroom-env
source ~/.headroom-env/bin/activate
pip install "headroom-ai[all]"
deactivate

echo "=== [4/6] MemStack ==="
mkdir -p ~/projects
cd ~/projects
if [ ! -d "memstack" ]; then
    git clone https://github.com/cwinvestments/memstack.git
fi
cd memstack
cp -n config.json config.local.json 2>/dev/null || true
python3 db/memstack-db.py init
pip install lancedb sentence-transformers --break-system-packages 2>/dev/null || true

echo "=== [5/6] Monitoramento ==="
pip install claude-monitor --break-system-packages 2>/dev/null || true

echo "=== [6/6] Configuração do Shell ==="
cat >> ~/.bashrc << 'BASHEOF'

# === Token Optimization Setup ===
export PATH="$HOME/.local/bin:$PATH"

# Headroom proxy
alias headroom-start='source ~/.headroom-env/bin/activate && headroom proxy --port 8787 &'
export ANTHROPIC_BASE_URL=http://127.0.0.1:8787

# RTK analytics
alias token-stats='rtk gain --graph'
alias token-discover='rtk discover'

# ccusage shortcuts
alias cc-daily='npx ccusage@latest daily'
alias cc-live='npx ccusage@latest blocks --live'
alias cc-session='npx ccusage@latest session'

# Claude Monitor
alias cc-monitor='cmonitor'
BASHEOF

source ~/.bashrc

echo ""
echo "============================================"
echo "  Setup completo!"
echo "============================================"
echo ""
echo "  Para iniciar uma sessão otimizada:"
echo "  1. headroom-start    (proxy de compressão)"
echo "  2. claude            (Claude Code)"
echo ""
echo "  Para monitorar:"
echo "  - token-stats        (economia do RTK)"
echo "  - cc-daily           (uso diário)"
echo "  - cc-live            (dashboard ao vivo)"
echo "  - cc-monitor         (monitor com previsões)"
echo ""
```

---

## Comparativo das Ferramentas

| Ferramenta | Camada | O que comprime | Como funciona | Economia |
|---|---|---|---|---|
| **RTK** | CLI | Output de comandos shell (git, cat, grep, test, build) | Binário Rust reescreve comandos transparentemente | 60-90% |
| **Headroom** | Proxy LLM | Todo contexto (JSON, código, logs, RAG, histórico) | Proxy entre app e LLM com múltiplos algoritmos | 47-92% |
| **MemStack** | Sessão | Re-explicação de contexto entre sessões | Memória SQLite + busca semântica + handoff | Variável |
| **ccusage** | Monitor | — (não comprime, mede) | Analisa JSONL local do Claude Code | — |
| **cmonitor** | Monitor | — (não comprime, mede) | Dashboard ao vivo com burn rate | — |

### Alternativas Investigadas (não recomendadas neste setup)

| Ferramenta | Por que não incluída |
|---|---|
| **Compresr.ai** | Cloud — envia dados para servidores externos |
| **Token Company** | Cloud — mesmo problema de privacidade |
| **token-optimizer-mcp** | MCP server com caching — mas adiciona overhead de MCP ao system prompt; melhor usar Headroom diretamente |
| **claude-token-efficient** | Apenas um CLAUDE.md otimizado — útil como referência para enxugar seu próprio CLAUDE.md, mas não é uma ferramenta |
| **everything-claude-code (ECC)** | Framework completo de skills/instincts — interessante mas muito pesado e genérico; MemStack é mais focado em memória e handoff |

---

## Referências

- RTK: https://github.com/rtk-ai/rtk (19.5k stars)
- Headroom: https://github.com/chopratejas/headroom (942 stars)
- MemStack: https://github.com/cwinvestments/memstack
- ccusage: https://github.com/ryoppippi/ccusage
- Claude Monitor: https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor
- Documentação oficial de custos: https://code.claude.com/docs/en/costs