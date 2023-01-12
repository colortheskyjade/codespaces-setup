if [ -f "/usr/share/bash-completion/completions/git" ]; then
    source /usr/share/bash-completion/completions/git
else
    echo "Error loading git completions"
fi

alias start="tmuxinator start vanta -p ~/.vanta_tmux.yml"
alias startweb="tmuxinator start vanta -p ~/.vanta_tmux.yml web web-client"

