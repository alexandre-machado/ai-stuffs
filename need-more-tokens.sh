#!/usr/bin/env bash
# Re-executa com bash se chamado via sh
if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi
set -euo pipefail

# ─────────────────────────────────────────────
#  Claude Code token saver
#  Headroom + RTK + MemStack
# ─────────────────────────────────────────────

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[·]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
die()     { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }

# ─── pré-requisitos ────────────────────────────────────────────────────────────

PYTHON=""

check_python() {
  # Prioridade: conda > python3.10/11/12 do sistema
  # Se conda está ativo, usa o Python dele (pip funciona sem restrições)
  local candidates=()
  if [[ -n "${CONDA_PREFIX:-}" ]]; then
    candidates+=("$CONDA_PREFIX/bin/python3" "$CONDA_PREFIX/bin/python")
  fi
  candidates+=(python3.12 python3.11 python3.10 python3)

  for cmd in "${candidates[@]}"; do
    if command -v "$cmd" &>/dev/null; then
      local ver
      ver=$("$cmd" -c "import sys; print(sys.version_info.major * 100 + sys.version_info.minor)" 2>/dev/null) || continue
      if [[ "$ver" -ge 310 ]]; then
        # Testa se pip funciona sem restrições (conda e venvs não bloqueiam)
        if "$cmd" -m pip install --dry-run --quiet "pip" &>/dev/null 2>&1; then
          PYTHON="$cmd"
          success "Python encontrado: $($cmd --version)"
          return
        fi
      fi
    fi
  done

  # Fallback: usa o primeiro python 3.10+ disponível mesmo com pip restrito,
  # e passa --break-system-packages nas chamadas de pip
  for cmd in python3.12 python3.11 python3.10 python3; do
    if command -v "$cmd" &>/dev/null; then
      local ver
      ver=$("$cmd" -c "import sys; print(sys.version_info.major * 100 + sys.version_info.minor)" 2>/dev/null) || continue
      if [[ "$ver" -ge 310 ]]; then
        PYTHON="$cmd"
        PIP_EXTRA_FLAGS="--break-system-packages"
        warn "Usando $($cmd --version) com --break-system-packages (ambiente gerenciado detectado)"
        warn "Recomendado: ative um ambiente conda ou venv antes de rodar este script"
        success "Python encontrado: $($cmd --version)"
        return
      fi
    fi
  done

  die "Python 3.10 ou superior não encontrado. Instale em https://python.org e rode novamente."
}

PIP_EXTRA_FLAGS=""

check_git() {
  command -v git &>/dev/null || die "git não está instalado."
  success "git $(git --version | awk '{print $3}')"
}

# ─── 1. Headroom ───────────────────────────────────────────────────────────────

install_headroom() {
  info "Instalando/Atualizando Headroom (compressão de contexto da API ~34–70%)..."

  $PYTHON -m pip install --upgrade --quiet $PIP_EXTRA_FLAGS "headroom-ai[proxy]" || \
    die "Falha ao instalar/atualizar headroom-ai. Tente manualmente: pip install --upgrade 'headroom-ai[proxy]'"
  success "Headroom instalado/atualizado"

  info "Instalando/Atualizando Headroom como servidor MCP no Claude Code..."
  headroom mcp install 2>/dev/null && success "Headroom MCP instalado" \
    || warn "headroom mcp install falhou — você pode rodar 'headroom proxy --port 8787' manualmente"

  # Persiste a variável de ambiente no shell
  local shell_rc=""
  if [[ "$SHELL" == *"zsh"* ]]; then
    shell_rc="$HOME/.zshrc"
  elif [[ "$SHELL" == *"bash"* ]]; then
    shell_rc="$HOME/.bashrc"
  fi

  if [[ -n "$shell_rc" ]]; then
    local export_line='export ANTHROPIC_BASE_URL="http://localhost:8787"'
    if ! grep -qF "$export_line" "$shell_rc" 2>/dev/null; then
      echo "" >> "$shell_rc"
      echo "# Headroom proxy — adicionado pelo setup do claude-token-saver" >> "$shell_rc"
      echo "$export_line" >> "$shell_rc"
      success "ANTHROPIC_BASE_URL adicionado em $shell_rc"
    else
      success "ANTHROPIC_BASE_URL já configurado em $shell_rc"
    fi
  else
    warn "Shell não identificado. Adicione manualmente no seu rc:"
    warn "  export ANTHROPIC_BASE_URL=\"http://localhost:8787\""
  fi
}

# ─── 2. RTK ────────────────────────────────────────────────────────────────────

install_rtk() {
  info "Instalando RTK (compressão de output do terminal 60–90%)..."

  if command -v rtk &>/dev/null; then
    success "RTK já instalado — $(rtk --version 2>/dev/null || echo 'versão desconhecida')"
  else
    local os
    os="$(uname -s)"
    if [[ "$os" == "Darwin" ]] && command -v brew &>/dev/null; then
      brew install rtk --quiet && success "RTK instalado via Homebrew"
    else
      info "Baixando script de instalação do RTK..."
      curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh \
        && success "RTK instalado" \
        || die "Falha na instalação do RTK. Veja: https://github.com/rtk-ai/rtk"
    fi
  fi

  info "Configurando hooks do RTK no Claude Code..."
  rtk init -g && success "Hooks do RTK instalados (interceptação automática ativa)" \
    || warn "rtk init -g falhou — rode manualmente depois de reiniciar o Claude Code"
}

# ─── 3. MemStack ───────────────────────────────────────────────────────────────

install_memstack() {
  info "Instalando MemStack (memória persistente entre sessões)..."

  local target=""

  echo ""
  echo -e "${CYAN}Onde instalar o MemStack?${NC}"
  echo "  1) Global (~/.claude/skills) — compartilhado entre todos os projetos"
  echo "  2) Projeto atual (./.claude/skills)"
  echo "  3) Caminho customizado"
  echo ""
  read -rp "Escolha [1]: " choice
  choice="${choice:-1}"

  case "$choice" in
    1) target="$HOME/.claude/skills" ;;
    2) target="$(pwd)/.claude/skills" ;;
    3)
      read -rp "Caminho: " custom_path
      target="${custom_path/#\~/$HOME}"
      ;;
    *) target="$HOME/.claude/skills" ;;
  esac

  if [[ -d "$target/.git" ]]; then
    info "MemStack já existe em $target — atualizando..."
    git -C "$target" pull --quiet && success "MemStack atualizado"
  else
    mkdir -p "$(dirname "$target")"
    git clone --quiet https://github.com/cwinvestments/memstack "$target" \
      && success "MemStack clonado em $target" \
      || die "Falha ao clonar o MemStack"
  fi

  if [[ ! -f "$target/config.local.json" ]] && [[ -f "$target/config.json" ]]; then
    cp "$target/config.json" "$target/config.local.json"
    info "config.local.json criado — edite para adicionar os caminhos dos seus projetos"
  fi

  info "Inicializando banco de dados do MemStack..."
  $PYTHON "$target/db/memstack-db.py" init \
    && success "Banco de dados do MemStack inicializado" \
    || warn "Falha na inicialização — rode manualmente: $PYTHON $target/db/memstack-db.py init"

  echo ""
  read -rp "Instalar busca semântica opcional (lancedb + sentence-transformers)? [s/N] " sem
  if [[ "$(echo "$sem" | tr '[:upper:]' '[:lower:]')" == "s" ]]; then
    $PYTHON -m pip install --quiet $PIP_EXTRA_FLAGS lancedb sentence-transformers \
      && success "Dependências de busca semântica instaladas" \
      || warn "Falha — instale manualmente: pip install lancedb sentence-transformers"
  fi

  MEMSTACK_PATH="$target"
}

# ─── Resumo ────────────────────────────────────────────────────────────────────

print_summary() {
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN} Instalação concluída. O que fazer agora:${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ${CYAN}1. Recarregue o shell${NC}"
  echo -e "     ${YELLOW}source ~/.zshrc${NC}  (ou ~/.bashrc)"
  echo ""
  echo -e "  ${CYAN}2. Headroom — inicie o proxy antes de abrir o Claude Code${NC}"
  echo -e "     O proxy precisa estar rodando para comprimir o tráfego da API."
  echo ""
  echo -e "     Opção A — inicia proxy e Claude Code juntos:"
  echo -e "     ${YELLOW}headroom wrap claude${NC}"
  echo ""
  echo -e "     Opção B — proxy em background, Claude Code separado:"
  echo -e "     ${YELLOW}headroom proxy --port 8787 &${NC}"
  echo -e "     ${YELLOW}claude${NC}"
  echo ""
  echo -e "     Para monitorar o que o Headroom está fazendo:"
  echo -e "     ${YELLOW}http://127.0.0.1:8787/stats${NC}  (abra no browser enquanto o proxy estiver rodando)"
  echo -e "     Ou dentro do Claude Code: peça ao Claude para usar a tool ${YELLOW}headroom_stats${NC}"
  echo ""
  echo -e "  ${CYAN}3. RTK — ativo automaticamente${NC}"
  echo -e "     Nenhuma ação necessária. Os hooks já interceptam os comandos do terminal."
  echo -e "     Para ver quanto está economizando: ${YELLOW}rtk gain${NC}"
  echo ""
  echo -e "  ${CYAN}4. MemStack — configure os caminhos dos seus projetos${NC}"
  echo -e "     Abra o arquivo: ${YELLOW}${MEMSTACK_PATH:-~/.claude/skills}/config.local.json${NC}"
  echo ""
  echo -e "     No campo ${YELLOW}\"projects\"${NC}, adicione cada projeto com um nome e o caminho:"
  echo -e "     ${YELLOW}\"projects\": {${NC}"
  echo -e "     ${YELLOW}  \"meu-projeto\": {${NC}"
  echo -e "     ${YELLOW}    \"dir\": \"/Users/seu-usuario/projetos/meu-projeto\",${NC}"
  echo -e "     ${YELLOW}    \"claude_md\": \"/Users/seu-usuario/projetos/meu-projeto/CLAUDE.md\"${NC}"
  echo -e "     ${YELLOW}  }${NC}"
  echo -e "     ${YELLOW}}${NC}"
  echo ""
  echo -e "     Sem isso, o MemStack não sabe onde buscar contexto e o Claude"
  echo -e "     continua relendo os arquivos do zero a cada sessão."
  echo ""
  echo -e "     Depois de configurar, rode uma vez dentro de cada projeto:"
  echo -e "     ${YELLOW}cd /caminho/do/projeto${NC}"
  echo -e "     ${YELLOW}$PYTHON ${MEMSTACK_PATH:-~/.claude/skills}/db/memstack-db.py init${NC}"
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ─── Main ──────────────────────────────────────────────────────────────────────

main() {
  echo ""
  echo -e "${CYAN}Claude Code token saver — Headroom + RTK + MemStack${NC}"
  echo ""

  check_python
  check_git
  echo ""

  install_headroom
  echo ""
  install_rtk
  echo ""
  install_memstack

  print_summary
}

main "$@"