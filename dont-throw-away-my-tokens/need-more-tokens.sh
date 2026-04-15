#!/usr/bin/env bash
# Re-executa com bash se chamado via sh
if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi
set -euo pipefail

# ─────────────────────────────────────────────
#  Claude Code token saver
#  Headroom + RTK + MemStack
#
#  Uso:
#    ./need-more-tokens.sh              # interativo (default)
#    ./need-more-tokens.sh -y            # não-interativo (CI, re-run)
#    ./need-more-tokens.sh --help
#
#  Variáveis de ambiente (úteis em modo -y):
#    MEMSTACK_CHOICE=global|project|/caminho  (default: global)
#    INSTALL_SEMANTIC=yes|no                  (default: no)
# ─────────────────────────────────────────────

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[·]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
die()     { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }

# ─── estado compartilhado ──────────────────────────────────────────────────────

PYTHON=""
PIP_EXTRA_FLAGS=""
ASSUME_YES=0
MEMSTACK_CHOICE="${MEMSTACK_CHOICE:-}"
INSTALL_SEMANTIC="${INSTALL_SEMANTIC:-}"

HEADROOM_OLD=""
HEADROOM_NEW=""
RTK_OLD=""
RTK_NEW=""
MEMSTACK_PATH=""
MEMSTACK_REV=""

print_help() {
  cat <<'EOF'
Claude Code token saver — Headroom + RTK + MemStack

Uso:
  ./need-more-tokens.sh [flags]

Flags:
  -y, --yes      Modo não-interativo. Usa defaults para todos os prompts.
  -h, --help     Mostra esta ajuda.

Variáveis de ambiente (efetivas com -y):
  MEMSTACK_CHOICE   global | project | /caminho/customizado  (default: global)
  INSTALL_SEMANTIC  yes | no                                  (default: no)

Exemplos:
  ./need-more-tokens.sh
  ./need-more-tokens.sh -y
  MEMSTACK_CHOICE=project INSTALL_SEMANTIC=yes ./need-more-tokens.sh -y
EOF
}

# ─── pré-requisitos ────────────────────────────────────────────────────────────

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

check_git() {
  command -v git &>/dev/null || die "git não está instalado."
  success "git $(git --version | awk '{print $3}')"
}

# Detecta o rc do shell (zsh, bash ou fallback .profile)
detect_shell_rc() {
  if [[ "${SHELL:-}" == *"zsh"* ]] && [[ -f "$HOME/.zshrc" ]]; then
    echo "$HOME/.zshrc"
  elif [[ "${SHELL:-}" == *"bash"* ]] && [[ -f "$HOME/.bashrc" ]]; then
    echo "$HOME/.bashrc"
  else
    echo "$HOME/.profile"
  fi
}

# Adiciona uma linha ao shell rc só se ainda não existir (idempotente)
append_to_rc_once() {
  local shell_rc="$1" marker="$2" line="$3"
  [[ -z "$shell_rc" ]] && return 1
  if grep -qF "$line" "$shell_rc" 2>/dev/null; then
    return 0  # já está lá
  fi
  {
    echo ""
    echo "# $marker — adicionado pelo setup do claude-token-saver"
    echo "$line"
  } >> "$shell_rc"
  return 0
}

# ─── 1. Headroom ───────────────────────────────────────────────────────────────

get_headroom_version() {
  $PYTHON -m pip show headroom-ai 2>/dev/null | awk '/^Version:/ {print $2}'
}

install_headroom() {
  info "Instalando/Atualizando Headroom (compressão de contexto da API ~34–70%)..."

  HEADROOM_OLD=$(get_headroom_version)

  # shellcheck disable=SC2086
  $PYTHON -m pip install --upgrade --quiet $PIP_EXTRA_FLAGS "headroom-ai[proxy]" || \
    die "Falha ao instalar/atualizar headroom-ai. Tente manualmente: pip install --upgrade 'headroom-ai[proxy]'"

  HEADROOM_NEW=$(get_headroom_version)

  if [[ -z "$HEADROOM_OLD" ]]; then
    success "Headroom instalado: $HEADROOM_NEW"
  elif [[ "$HEADROOM_OLD" == "$HEADROOM_NEW" ]]; then
    success "Headroom já atualizado ($HEADROOM_NEW)"
  else
    success "Headroom: $HEADROOM_OLD → $HEADROOM_NEW"
  fi

  info "Registrando Headroom como servidor MCP no Claude Code..."
  if headroom mcp install &>/dev/null; then
    success "Headroom MCP registrado"
  else
    warn "headroom mcp install falhou ou já estava registrado — ignorando"
  fi

  # Persiste ANTHROPIC_BASE_URL no rc (idempotente)
  local shell_rc
  shell_rc=$(detect_shell_rc)
  local export_line='export ANTHROPIC_BASE_URL="http://localhost:8787"'

  if [[ -n "$shell_rc" ]]; then
    if append_to_rc_once "$shell_rc" "Headroom proxy" "$export_line"; then
      if grep -qF "$export_line" "$shell_rc" 2>/dev/null; then
        success "ANTHROPIC_BASE_URL configurado em $shell_rc"
      fi
    fi
  else
    warn "Shell não identificado. Adicione manualmente no seu rc:"
    warn "  $export_line"
  fi
}

# ─── 2. RTK ────────────────────────────────────────────────────────────────────

get_rtk_version() {
  if command -v rtk &>/dev/null; then
    rtk --version 2>/dev/null | awk '{print $2}' || echo "instalado"
  elif [[ -x "$HOME/.local/bin/rtk" ]]; then
    "$HOME/.local/bin/rtk" --version 2>/dev/null | awk '{print $2}' || echo "instalado"
  fi
}

install_rtk() {
  info "Instalando/Atualizando RTK (compressão de output do terminal 60–90%)..."

  RTK_OLD=$(get_rtk_version)

  local os
  os="$(uname -s)"
  if [[ "$os" == "Darwin" ]] && command -v brew &>/dev/null; then
    # brew upgrade falha se não estiver instalado; fallback pra install
    if ! brew upgrade rtk --quiet &>/dev/null; then
      brew install rtk --quiet || die "Falha ao instalar RTK via Homebrew"
    fi
  else
    info "Rodando instalador oficial do RTK..."
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh \
      || die "Falha na instalação do RTK. Veja: https://github.com/rtk-ai/rtk"
  fi

  # Garante que ~/.local/bin está no PATH para este script enxergar rtk
  if [[ ! "$PATH" == *"$HOME/.local/bin"* ]] && [[ -x "$HOME/.local/bin/rtk" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
  fi

  RTK_NEW=$(get_rtk_version)

  if [[ -z "$RTK_NEW" ]]; then
    die "RTK foi instalado mas o binário não foi encontrado no PATH nem em ~/.local/bin"
  fi

  if [[ -z "$RTK_OLD" ]]; then
    success "RTK instalado: $RTK_NEW"
  elif [[ "$RTK_OLD" == "$RTK_NEW" ]]; then
    success "RTK já atualizado ($RTK_NEW)"
  else
    success "RTK: $RTK_OLD → $RTK_NEW"
  fi

  # Garante que o PATH está configurado permanentemente
  if [[ -x "$HOME/.local/bin/rtk" ]]; then
    local shell_rc
    shell_rc=$(detect_shell_rc)
    local path_line='export PATH="$HOME/.local/bin:$PATH"'
    if [[ -n "$shell_rc" ]]; then
      if append_to_rc_once "$shell_rc" "RTK PATH" "$path_line"; then
        if grep -qF "$path_line" "$shell_rc" 2>/dev/null; then
          success "~/.local/bin garantido no PATH via $shell_rc"
        fi
      fi
    fi
  fi

  info "Configurando hooks do RTK no Claude Code..."
  if rtk init -g &>/dev/null; then
    success "Hooks do RTK instalados (interceptação automática ativa)"
  else
    warn "rtk init -g falhou — rode manualmente depois de reiniciar o Claude Code"
  fi
}

# ─── 3. MemStack ───────────────────────────────────────────────────────────────

resolve_memstack_target() {
  # Honra MEMSTACK_CHOICE / ASSUME_YES antes de prompts
  if [[ -n "$MEMSTACK_CHOICE" ]]; then
    case "$MEMSTACK_CHOICE" in
      global)  echo "$HOME/.claude/skills" ;;
      project) echo "$(pwd)/.claude/skills" ;;
      /*|~*)   echo "${MEMSTACK_CHOICE/#\~/$HOME}" ;;
      *)       echo "$HOME/.claude/skills" ;;
    esac
    return
  fi

  if [[ "$ASSUME_YES" == "1" ]]; then
    echo "$HOME/.claude/skills"
    return
  fi

  echo "" >&2
  echo -e "${CYAN}Onde instalar o MemStack?${NC}" >&2
  echo "  1) Global (~/.claude/skills) — compartilhado entre todos os projetos" >&2
  echo "  2) Projeto atual (./.claude/skills)" >&2
  echo "  3) Caminho customizado" >&2
  echo "" >&2
  local choice custom_path
  read -rp "Escolha [1]: " choice
  choice="${choice:-1}"

  case "$choice" in
    1) echo "$HOME/.claude/skills" ;;
    2) echo "$(pwd)/.claude/skills" ;;
    3)
      read -rp "Caminho: " custom_path
      echo "${custom_path/#\~/$HOME}"
      ;;
    *) echo "$HOME/.claude/skills" ;;
  esac
}

update_memstack_repo() {
  local target="$1"

  # Pula update se working tree estiver sujo (preserva mudanças do usuário)
  if ! git -C "$target" diff --quiet 2>/dev/null || ! git -C "$target" diff --cached --quiet 2>/dev/null; then
    warn "MemStack em $target tem mudanças locais — pulando update para não sobrescrever"
    warn "Para forçar update: (cd '$target' && git stash && git pull && git stash pop)"
    MEMSTACK_REV=$(git -C "$target" rev-parse --short HEAD 2>/dev/null || echo "?")
    return 0
  fi

  local before after
  before=$(git -C "$target" rev-parse --short HEAD 2>/dev/null || echo "")
  git -C "$target" fetch --quiet origin 2>/dev/null || {
    warn "MemStack: fetch falhou (offline?) — mantendo versão atual"
    MEMSTACK_REV="$before"
    return 0
  }

  if git -C "$target" merge --ff-only --quiet FETCH_HEAD 2>/dev/null; then
    after=$(git -C "$target" rev-parse --short HEAD)
    if [[ "$before" == "$after" ]]; then
      success "MemStack já atualizado ($after)"
    else
      success "MemStack: $before → $after"
    fi
    MEMSTACK_REV="$after"
  else
    warn "MemStack: fast-forward falhou (branch divergiu). Update manual necessário."
    MEMSTACK_REV="$before"
  fi
}

install_semantic_search() {
  # Checa se já está instalado (idempotente)
  if $PYTHON -c "import lancedb, sentence_transformers" &>/dev/null; then
    success "Busca semântica já instalada (lancedb + sentence-transformers)"
    return
  fi

  # Decide se instala (sem prompt em modo -y)
  local want=""
  if [[ -n "$INSTALL_SEMANTIC" ]]; then
    want="$INSTALL_SEMANTIC"
  elif [[ "$ASSUME_YES" == "1" ]]; then
    want="no"
  else
    echo ""
    info "Sim: instala lancedb + sentence-transformers e habilita busca semântica."
    info "Não: mantém o setup mais leve e rápido, mas a busca semântica fica indisponível."
    local sem
    read -rp "Instalar busca semântica opcional (lancedb + sentence-transformers)? [s/N] " sem
    case "$(echo "$sem" | tr '[:upper:]' '[:lower:]')" in
      s|sim|y|yes) want="yes" ;;
      *) want="no" ;;
    esac
  fi

  if [[ "$want" == "yes" ]]; then
    info "Instalando lancedb + sentence-transformers..."
    # shellcheck disable=SC2086
    if $PYTHON -m pip install --quiet $PIP_EXTRA_FLAGS lancedb sentence-transformers; then
      success "Dependências de busca semântica instaladas"
    else
      warn "Falha — instale manualmente: pip install lancedb sentence-transformers"
    fi
  else
    info "Busca semântica pulada (setup mais leve e sem busca semântica)"
  fi
}

install_memstack() {
  info "Instalando MemStack (memória persistente entre sessões)..."

  local target
  target=$(resolve_memstack_target)
  MEMSTACK_PATH="$target"

  if [[ -d "$target/.git" ]]; then
    info "MemStack já existe em $target — verificando atualizações..."
    update_memstack_repo "$target"
  else
    mkdir -p "$(dirname "$target")"
    if git clone --quiet https://github.com/cwinvestments/memstack "$target"; then
      success "MemStack clonado em $target"
      MEMSTACK_REV=$(git -C "$target" rev-parse --short HEAD 2>/dev/null || echo "?")
    else
      die "Falha ao clonar o MemStack"
    fi
  fi

  # Cria config.local.json só se não existir (preserva customizações)
  if [[ ! -f "$target/config.local.json" ]] && [[ -f "$target/config.json" ]]; then
    cp "$target/config.json" "$target/config.local.json"
    info "config.local.json criado — edite para adicionar os caminhos dos seus projetos"
  fi

  info "Inicializando banco de dados do MemStack..."
  if $PYTHON "$target/db/memstack-db.py" init 2>/dev/null; then
    success "Banco de dados do MemStack inicializado"
  else
    warn "Falha na inicialização — rode manualmente: $PYTHON $target/db/memstack-db.py init"
  fi

  # Cria alias `memstack` no rc do shell pra simplificar `memstack init`, `memstack stats`, etc.
  local shell_rc
  shell_rc=$(detect_shell_rc)
  local alias_line="alias memstack='$PYTHON \"$target/db/memstack-db.py\"'"
  if [[ -n "$shell_rc" ]]; then
    if append_to_rc_once "$shell_rc" "MemStack alias" "$alias_line"; then
      grep -qF "$alias_line" "$shell_rc" 2>/dev/null && success "alias 'memstack' configurado em $shell_rc"
    fi
  fi

  install_semantic_search
}

# ─── Resumo ────────────────────────────────────────────────────────────────────

print_summary() {
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN} Instalação concluída.${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ${CYAN}Versões instaladas:${NC}"
  echo -e "     Headroom: ${YELLOW}${HEADROOM_NEW:-?}${NC}"
  echo -e "     RTK:      ${YELLOW}${RTK_NEW:-?}${NC}"
  echo -e "     MemStack: ${YELLOW}${MEMSTACK_REV:-?}${NC} em ${MEMSTACK_PATH:-?}"
  echo ""
  echo -e "${GREEN} O que fazer agora:${NC}"
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
  echo -e "     ${YELLOW}cd /caminho/do/projeto && memstack init${NC}"
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ─── Main ──────────────────────────────────────────────────────────────────────

parse_args() {
  for arg in "$@"; do
    case "$arg" in
      -y|--yes) ASSUME_YES=1 ;;
      -h|--help) print_help; exit 0 ;;
      *) die "Flag desconhecida: $arg (use --help)" ;;
    esac
  done
}

main() {
  parse_args "$@"

  echo ""
  echo -e "${CYAN}Claude Code token saver — Headroom + RTK + MemStack${NC}"
  if [[ "$ASSUME_YES" == "1" ]]; then
    echo -e "${CYAN}(modo não-interativo)${NC}"
  fi
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
