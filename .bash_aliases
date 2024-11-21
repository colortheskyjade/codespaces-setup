if [ -f "/usr/share/bash-completion/completions/git" ]; then
    source /usr/share/bash-completion/completions/git
else
    echo "Error loading git completions"
fi

# No more green backgrounds for writeable folders.
export LS_COLORS+=':ow=01;33'

alias rrr="yarn post-pull && make dev-replace web web-client"
alias ypp="yarn post-pull"
alias mmm="make generate-types && make dev-start web web-client"
