if [ -f "/usr/share/bash-completion/completions/git" ]; then
    source /usr/share/bash-completion/completions/git
else
    echo "Error loading git completions"
fi

# No more green backgrounds for writeable folders.
export LS_COLORS+=':ow=01;33'
export DOZZLE_ENABLE_ACTIONS=true

alias jpp="just post-pull"
alias ypp="just post-pull"

# Docker compose logs alias
logs() {
    if [ $# -eq 0 ]; then
        echo "Usage: logs [service-name] [-t] [-n]"
        return 1
    fi
    
    local service="$1"
    shift
    
    docker-compose logs "$@" "$service"
}

# Dozzle docker logs viewer
alias dozzle="docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 12345:8080 --name dozzle amir20/dozzle:latest"
