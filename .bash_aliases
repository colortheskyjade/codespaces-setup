if [ -f "/usr/share/bash-completion/completions/git" ]; then
    source /usr/share/bash-completion/completions/git
else
    echo "Error loading git completions"
fi

# No more green backgrounds for writeable folders.
export LS_COLORS+=':ow=01;33'

alias start="tmuxinator start vanta -p ~/.vanta_tmux.yml"
alias startweb="tmuxinator start vanta -p ~/.vanta_tmux.yml web web-client"
alias stop="tmux kill-session -t vanta"

alias makefix="make linter-autofix"
alias makestory="make dev-storybook"
alias maketypes="make generate-types"
alias makeweb="make dev-start web web-client"
