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

# List most recent local branches
alias ghlocal="git for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:relative) %(align:width=15)%(refname:short)%(end)'"

if command -v cursor >/dev/null 2>&1; then
    export GIT_EDITOR="cursor --wait"
elif command -v code >/dev/null 2>&1; then
    export GIT_EDITOR="code --wait"
fi

# New random branch
newbranch() {
  # Generate a 8-digit hex code (4 bytes)
  local HEX_CODE=$(openssl rand -hex 4)
  local BRANCH_NAME="ruyan_$HEX_CODE"
  
  # Check if we are in a Git repository
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    # Create the branch and switch to it
    git checkout -b "$BRANCH_NAME"
    echo ""
    echo "✨ Switched to new branch: **$BRANCH_NAME**"
  else
    echo "🚫 Error: Not inside a Git repository."
    echo "Generated name (not used): **$BRANCH_NAME**"
    return 1
  fi
}
