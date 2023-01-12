#!/usr/bin/env bash

set -o errexit  # Exit if a command fails
set -o nounset  # Exit when using an undeclared variable
set -o pipefail # Catch pipe failures

ln -s .bash_aliases $HOME/.bash_aliases
ln -s .tmux.conf $HOME/.tmux.conf
tmux source-file $HOME/.tmux.conf