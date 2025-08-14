#!/usr/bin/env bash
# Co-Driver / csuggest installer (minimal, idempotent)
# - Installs csuggest to ~/.local/bin
# - Installs Ollama if missing, starts it, and pulls a lightweight multilingual model
# - Adds a zsh widget bound to Ctrl+@ to inline-replace the current command line
# - DOES NOT call `exec zsh -l` (user runs it later)
set -euo pipefail

CSUGGEST_URL="https://raw.githubusercontent.com/mimikonadeshiko/Co-Driver/refs/heads/main/csuggest"
BIN_DIR="${HOME}/.local/bin"
BIN_PATH="${BIN_DIR}/csuggest"
ZSHRC="${HOME}/.zshrc"
MODEL_DEFAULT="qwen2.5:7b-instruct-q4_K_M"

WIDGET_MARK_START="# >>> Co-Driver csuggest widget start >>>"
WIDGET_MARK_END="# <<< Co-Driver csuggest widget end <<<"

log()  { printf "%b\n" "[$(tput bold)Co-Driver$(tput sgr0)] $*"; }
warn() { printf "%b\n" "[$(tput setaf 3)WARN$(tput sgr0)] $*"; }
err()  { printf "%b\n" "[$(tput setaf 1)ERROR$(tput sgr0)] $*"; }

ensure_dir() { mkdir -p "$1"; }

append_block_once() {
  # $1=file, $2=start_marker, $3=end_marker, $4=content
  local f="$1" start="$2" end="$3" content="$4"
  if [ -f "$f" ] && grep -qF "$start" "$f"; then
    log "Widget block already present in ${f} (skip)"
  else
    log "Append widget block to ${f}"
    {
      printf "\n%s\n" "$start"
      printf "%s\n" "$content"
      printf "%s\n" "$end"
    } >> "$f"
  fi
}

install_csuggest() {
  log "Installing csuggest to ${BIN_PATH}"
  ensure_dir "$BIN_DIR"
  curl -fsSL "$CSUGGEST_URL" -o "$BIN_PATH"
  chmod +x "$BIN_PATH"
}

install_ollama_if_needed() {
  if command -v ollama >/dev/null 2>&1; then
    log "Ollama already installed."
  else
    log "Installing Ollama via official script..."
    curl -fsSL https://ollama.com/install.sh | sh
  fi

  if pgrep -x ollama >/dev/null 2>&1; then
    log "Ollama is running."
  else
    log "Starting ollama serve in background..."
    (nohup ollama serve >/dev/null 2>&1 &)
    sleep 1
  fi

  log "Ensuring model available: ${MODEL_DEFAULT}"
  if ! ollama list 2>/dev/null | awk '{print $1}' | grep -qx "$MODEL_DEFAULT"; then
    ollama pull "$MODEL_DEFAULT" || warn "Model pull failed. Try later: ollama pull ${MODEL_DEFAULT}"
  fi
}

ensure_path() {
  # Add ~/.local/bin to PATH via ~/.zshrc if not already exported
  if ! printf "%s" "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
    if [ -f "$ZSHRC" ] && grep -qF "$BIN_DIR" "$ZSHRC"; then
      log "~/.local/bin already exported in ${ZSHRC}."
    else
      log "Export ~/.local/bin to PATH in ${ZSHRC}"
      printf '\n# Add ~/.local/bin to PATH for csuggest\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$ZSHRC"
    fi
  else
    log "~/.local/bin already in PATH (current session)."
  fi
}

setup_zsh_widget() {
  log "Configuring zsh widget (default: Ctrl+@)"

  [ -f "$ZSHRC" ] || : > "$ZSHRC"

  read -r -d '' WIDGET <<'EOF' || true
# Inline-replace current command line using csuggest
# NOTE: If Ctrl+@ doesn't work in your terminal, change '^@' below to '^B' (Ctrl+B) or another key.
codriver_widget_csuggest() {
  local bin="${HOME}/.local/bin/csuggest"
  if [ -x "$bin" ]; then
    BUFFER="$("$bin" "$BUFFER")"
    CURSOR=$#BUFFER
    zle redisplay
  else
    echo "csuggest not found at $bin" >&2
  fi
}
zle -N codriver_widget_csuggest
bindkey '^@' codriver_widget_csuggest
# Optional environment hints:
# export CODRIVER_ENDPOINT="http://127.0.0.1:11434"
EOF

  append_block_once "$ZSHRC" "$WIDGET_MARK_START" "$WIDGET_MARK_END" "$WIDGET"
}

main() {
  command -v curl >/dev/null 2>&1 || { err "curl is required."; exit 1; }

  install_csuggest
  install_ollama_if_needed
  ensure_path
  setup_zsh_widget

  cat <<'MSG'

✅ インストール完了

- 反映するには、あとで以下を実行してください（このスクリプトでは実行しません）:
    exec zsh -l

- Ctrl+@ が使えない場合は、~/.zshrc 内の
    bindkey '^@' codriver_widget_csuggest
  を例えば
    bindkey '^B' codriver_widget_csuggest
  に変更してから、再度:
    exec zsh -l

Code Away !!! 🚗💨
MSG
}

main "$@"
