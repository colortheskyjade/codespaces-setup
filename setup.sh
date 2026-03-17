#!/usr/bin/env bash

set -Eeuo pipefail

sudo apt-get install -y stow
stow -t ~ home

echo "session_name \"$(gitpod env get -f Name)\"" >> ~/.config/zellij/config.kdl
sudo git config --global user.email "colortheskyjade@users.noreply.github.com"

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

