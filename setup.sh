#!/usr/bin/env bash

set -uo pipefail

errors=()

step() {
  echo "==> $1"
}

try() {
  local name="$1"; shift
  step "$name"
  if ! "$@"; then
    errors+=("$name")
    echo "  !! FAILED: $name" >&2
  fi
}

# --- Core packages (bail if this fails, nothing else will work) ---
step "Installing base packages"
sudo apt-get update
sudo apt-get install -y stow make gcc ripgrep unzip git xclip curl mosh

# --- Neovim nightly ---
nvim_arch="$(uname -m)"
case "$nvim_arch" in
  x86_64)  nvim_tar="nvim-linux-x86_64.tar.gz" ;;
  aarch64) nvim_tar="nvim-linux-arm64.tar.gz" ;;
  *)       nvim_tar="" ;;
esac

if [[ -n "$nvim_tar" ]]; then
  try "Neovim nightly" bash -c "
    nvim_root=\"/usr/local/${nvim_tar%.tar.gz}\"
    sudo rm -rf \"\$nvim_root\"
    curl -fsSL \"https://github.com/neovim/neovim/releases/download/nightly/${nvim_tar}\" | sudo tar xz -C /usr/local
    sudo ln -sfn \"\${nvim_root}/bin/nvim\" /usr/local/bin/nvim
  "
else
  echo "  !! Skipping Neovim: unsupported arch ${nvim_arch}" >&2
  errors+=("Neovim (unsupported arch)")
fi

# --- Dotfiles via stow ---
mkdir -p ~/.config
try "Stow dotfiles" stow --no-folding --restow -t ~ home
ln -sf ~/AGENTS.md ~/.claude/CLAUDE.md 2>/dev/null || true
try "Claude config" claude config set --global trustCurrentFolder true

if command -v gitpod >/dev/null 2>&1; then
  ona_name="$(gitpod env get -f Name 2>/dev/null || true)"
  if [[ -n "$ona_name" ]]; then
    sed -i '/^session_name /d' ~/.config/zellij/config.kdl 2>/dev/null || true
    echo "session_name \"${ona_name}\"" >> ~/.config/zellij/config.kdl
  fi
fi

# --- Seed Cursor CLI default model (Opus 4.6 1M) ---
CURSOR_CLI_CONFIG="$HOME/.cursor/cli-config.json"
mkdir -p "$(dirname "$CURSOR_CLI_CONFIG")"
if [ ! -f "$CURSOR_CLI_CONFIG" ]; then
  cat > "$CURSOR_CLI_CONFIG" <<'CURSOR_EOF'
{
  "version": 1,
  "model": {
    "modelId": "claude-4.6-opus-high",
    "displayModelId": "claude-4.6-opus-high",
    "displayName": "Opus 4.6 1M",
    "displayNameShort": "Opus 4.6 1M",
    "aliases": [],
    "maxMode": true
  },
  "hasChangedDefaultModel": true,
  "selectedModel": {
    "modelId": "claude-4.6-opus-high",
    "parameters": []
  },
  "modelParameters": {
    "claude-4.6-opus-high": []
  },
  "approvalMode": "auto-approve"
}
CURSOR_EOF
elif command -v jq >/dev/null 2>&1; then
  tmp="$(mktemp)"
  jq '
    .model = {
      "modelId": "claude-4.6-opus-high",
      "displayModelId": "claude-4.6-opus-high",
      "displayName": "Opus 4.6 1M",
      "displayNameShort": "Opus 4.6 1M",
      "aliases": [],
      "maxMode": true
    } |
    .hasChangedDefaultModel = true |
    .selectedModel = {
      "modelId": "claude-4.6-opus-high",
      "parameters": []
    } |
    .modelParameters = {
      "claude-4.6-opus-high": []
    } |
    .approvalMode = "auto-approve"
  ' "$CURSOR_CLI_CONFIG" > "$tmp" && mv "$tmp" "$CURSOR_CLI_CONFIG"
fi

# --- Homebrew ---
BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"
BREW_SHELLENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

if ! command -v brew >/dev/null 2>&1 && [[ ! -x "$BREW_BIN" ]]; then
  try "Homebrew install" bash -c "NONINTERACTIVE=1 /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
fi

if [[ -x "$BREW_BIN" ]]; then
  eval "$("$BREW_BIN" shellenv)"

  for shell_rc in ~/.bashrc ~/.profile; do
    touch "$shell_rc"
    if ! grep -Fqx "$BREW_SHELLENV" "$shell_rc"; then
      printf '\n%s\n' "$BREW_SHELLENV" >> "$shell_rc"
    fi
  done

  try "Brew packages" brew install git-delta fd fzf bat jj
else
  echo "  !! Skipping brew packages: brew not available" >&2
  errors+=("Brew packages (brew not found)")
fi

# --- mise ---
try "mise install" bash -c "curl -fsSL https://mise.run | sh"

if command -v mise >/dev/null 2>&1 || [[ -x "${HOME}/.local/bin/mise" ]]; then
  export PATH="${HOME}/.local/bin:${PATH}"
  try "mise node LTS" mise use --global node@lts
  try "npm global tools" mise x -- npm install -g @typescript/native-preview tree-sitter-cli
else
  echo "  !! Skipping mise tools: mise not available" >&2
  errors+=("mise tools (mise not found)")
fi

# --- git-spice ---
try "git-spice" bash -c \
  "curl -fsSL \"https://github.com/abhinav/git-spice/releases/latest/download/git-spice.Linux-\$(uname -m).tar.gz\" | sudo tar xz -C /usr/local/bin"

# --- Zellij ---
zellij_arch="$(uname -m)"
case "$zellij_arch" in
  x86_64)  zellij_tar="zellij-x86_64-unknown-linux-musl.tar.gz" ;;
  aarch64) zellij_tar="zellij-aarch64-unknown-linux-musl.tar.gz" ;;
  *)       zellij_tar="" ;;
esac

if [[ -n "$zellij_tar" ]]; then
  try "Zellij" bash -c \
    "curl -fsSL \"https://github.com/zellij-org/zellij/releases/latest/download/${zellij_tar}\" | sudo tar xz -C /usr/local/bin"
else
  echo "  !! Skipping Zellij: unsupported arch ${zellij_arch}" >&2
  errors+=("Zellij (unsupported arch)")
fi

# --- Summary ---
echo ""
if [[ ${#errors[@]} -eq 0 ]]; then
  echo "==> All steps completed successfully."
else
  echo "==> Setup finished with ${#errors[@]} failed step(s):"
  for e in "${errors[@]}"; do
    echo "  - $e"
  done
  exit 1
fi
