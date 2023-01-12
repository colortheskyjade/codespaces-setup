#!/usr/bin/env bash

set -o errexit  # Exit if a command fails
set -o nounset  # Exit when using an undeclared variable
set -o pipefail # Catch pipe failures

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

ln -s $scriptDir/.bash_aliases $HOME/.bash_aliases
ln -s $scriptDir/.tmux.conf $HOME/.tmux.conf
tmux source-file $HOME/.tmux.conf