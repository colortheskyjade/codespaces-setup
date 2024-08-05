if [ -f "/usr/share/bash-completion/completions/git" ]; then
    source /usr/share/bash-completion/completions/git
else
    echo "Error loading git completions"
fi

# No more green backgrounds for writeable folders.
export LS_COLORS+=':ow=01;33'

alias rrr="make yarn && make generate-types && make dev-replace web web-client"
