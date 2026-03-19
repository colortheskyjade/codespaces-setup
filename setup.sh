#!/usr/bin/env bash

set -Eeuo pipefail

sudo apt-get update
sudo apt-get install -y software-properties-common stow
sudo add-apt-repository ppa:neovim-ppa/stable -y
sudo apt-get update
sudo apt-get install -y make gcc ripgrep fd-find tree-sitter-cli unzip git xclip neovim
mkdir -p ~/.config
stow --restow -t ~ home

echo "session_name \"$(gitpod env get -f Name)\"" >> ~/.config/zellij/config.kdl
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

# Tool installation
mise use --global delta@0.18.2 \
  'ubi:abhinav/git-spice[exe=gs]' \
  fd@10.2.0 \
  fzf@0.65.0 \
  bat@0.25.0 \
  jujutsu@0.31.0

curl -fsSL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz \
  | sudo tar xz -C /usr/local/bin

docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 12345:8080 \
  --name dozzle \
  amir20/dozzle:latest

