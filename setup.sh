#!/usr/bin/env bash

set -Eeuo pipefail

sudo apt-get update
sudo apt-get install -y stow make gcc ripgrep unzip git xclip curl mosh

# Neovim nightly from GitHub (prerelease), not the stable PPA build
nvim_arch="$(uname -m)"
case "$nvim_arch" in
  x86_64) nvim_tar="nvim-linux-x86_64.tar.gz" ;;
  aarch64) nvim_tar="nvim-linux-arm64.tar.gz" ;;
  *)
    echo "setup.sh: Neovim nightly: unsupported uname -m: ${nvim_arch}" >&2
    exit 1
    ;;
esac
nvim_root="/usr/local/${nvim_tar%.tar.gz}"
sudo rm -rf "$nvim_root"
curl -fsSL "https://github.com/neovim/neovim/releases/download/nightly/${nvim_tar}" | sudo tar xz -C /usr/local
sudo ln -sfn "${nvim_root}/bin/nvim" /usr/local/bin/nvim
mkdir -p ~/.config
stow --no-folding --restow -t ~ home 2>/dev/null
ln -sf ~/AGENTS.md ~/.claude/CLAUDE.md

if command -v gitpod >/dev/null 2>&1; then
  echo "session_name \"$(gitpod env get -f Name)\"" >> ~/.config/zellij/config.kdl
fi
sudo git config --global user.email "colortheskyjade@users.noreply.github.com"

# Install Homebrew for Linux and make it available in future shells.
BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"
BREW_SHELLENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

if ! command -v brew >/dev/null 2>&1 && [[ ! -x "$BREW_BIN" ]]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x "$BREW_BIN" ]]; then
  eval "$("$BREW_BIN" shellenv)"

  for shell_rc in ~/.bashrc ~/.profile; do
    touch "$shell_rc"
    if ! grep -Fqx "$BREW_SHELLENV" "$shell_rc"; then
      printf '\n%s\n' "$BREW_SHELLENV" >> "$shell_rc"
    fi
  done
fi

# Install mise
curl https://mise.run | sh

brew install git-delta fd fzf bat jj

curl -fsSL "https://github.com/abhinav/git-spice/releases/latest/download/git-spice.Linux-$(uname -m).tar.gz" \
  | sudo tar xz -C /usr/local/bin

# mise: node + npm-installed tools
mise use --global node@lts
export PATH="${HOME}/.local/bin:${PATH}"
mise x -- npm install -g @typescript/native-preview tree-sitter-cli

zellij_arch="$(uname -m)"
case "$zellij_arch" in
  x86_64)  zellij_tar="zellij-x86_64-unknown-linux-musl.tar.gz" ;;
  aarch64) zellij_tar="zellij-aarch64-unknown-linux-musl.tar.gz" ;;
  *)
    echo "setup.sh: Zellij: unsupported uname -m: ${zellij_arch}" >&2
    exit 1
    ;;
esac
curl -fsSL "https://github.com/zellij-org/zellij/releases/latest/download/${zellij_tar}" \
  | sudo tar xz -C /usr/local/bin


