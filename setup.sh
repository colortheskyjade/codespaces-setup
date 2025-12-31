#!/usr/bin/env bash

set -Eeuo pipefail

# copy dotfiles
cp .gitconfig .tmux.conf .bash_aliases ~/
git config --global user.email "colortheskyjade@users.noreply.github.com"

# copy claude files
mkdir -p ~/.claude
cp .claude_settings.json ~/.claude/settings.json
cp CLAUDE.md ~/.claude/
cp -r claude/* ~/.claude/

# Install mise
curl https://mise.run | sh

# Tool installation
mise use --global delta@0.18.2 \
  'ubi:abhinav/git-spice[exe=gs]' \
  fd@10.2.0 \
  fzf@0.65.0 \
  bat@0.25.0 \
  jujutsu@0.31.0

docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 12345:8080 \
  --name dozzle \
  amir20/dozzle:latest

sudo git config --system --unset include.path
