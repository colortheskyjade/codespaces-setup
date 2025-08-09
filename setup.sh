#!/usr/bin/env bash

set -Eeuo pipefail

# copy dotfiles
cp .gitconfig .tmux.conf .bash_aliases ~/

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
