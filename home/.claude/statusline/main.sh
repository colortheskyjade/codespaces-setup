#!/usr/bin/env bash
# Statusline dispatcher — delegates to named script via STATUSLINE_SCRIPT env var
# Lookup order: ~/.claude/statusline/ → .claude/statusline/ → absolute path → fallback to full

DIR="$(cd "$(dirname "$0")" && pwd)"
NAME="${STATUSLINE_SCRIPT:-simple}"

# Look up by name in two directories (user home first, then project)
for search_dir in "$HOME/.claude/statusline" "$DIR"; do
    if [[ -x "$search_dir/$NAME.sh" ]]; then
        exec "$search_dir/$NAME.sh"
    fi
done

# Fallback: treat as absolute path
if [[ -x "$NAME" ]]; then
    exec "$NAME"
fi

# Last resort: run full from project
exec "$DIR/full.sh"
