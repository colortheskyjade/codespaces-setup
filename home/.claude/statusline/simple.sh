#!/bin/bash
# Claude Code statusline — [model] 🌿 branch* context%

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"' | sed -E 's/Claude //i; s/ \(with .*\)//i; s/ /-/g; s/(.)/\L\1/g')
FULL_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
USED_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# Git branch + dirty
BRANCH=""
DIRTY=""
if git -C "$FULL_DIR" rev-parse --git-dir &>/dev/null; then
    GIT_STATUS=$(git -C "$FULL_DIR" --no-optional-locks status -b --porcelain=v2 2>/dev/null)
    BRANCH=$(echo "$GIT_STATUS" | grep '^# branch.head ' | cut -d' ' -f3)
    if echo "$GIT_STATUS" | grep -qE '^[12?] '; then
        DIRTY="*"
    fi
fi

# Context color
USED_PCT_INT=${USED_PCT%.*}
[ -z "$USED_PCT_INT" ] && USED_PCT_INT=0
CTX_COLOR="\033[32m"
if [ "$CONTEXT_SIZE" -gt 0 ] 2>/dev/null; then
    COMPACT_PCT=$(( (CONTEXT_SIZE - 33000) * 100 / CONTEXT_SIZE ))
    (( USED_PCT_INT >= COMPACT_PCT )) && CTX_COLOR="\033[1;31m"
    (( USED_PCT_INT < COMPACT_PCT && USED_PCT_INT >= COMPACT_PCT - 10 )) && CTX_COLOR="\033[1;33m"
    (( USED_PCT_INT >= 50 && USED_PCT_INT < COMPACT_PCT - 10 )) && CTX_COLOR="\033[33m"
fi

# Truncate branch
DISPLAY_BRANCH="$BRANCH"
if (( ${#BRANCH} > 25 )); then
    DISPLAY_BRANCH="${BRANCH:0:22}..."
fi

# Assemble
PARTS="\033[36m[${MODEL}]\033[0m"
[ -n "$BRANCH" ] && PARTS="$PARTS 🌿 \033[33m${DISPLAY_BRANCH}\033[0m\033[31m${DIRTY}\033[0m"
(( USED_PCT_INT > 0 )) && PARTS="$PARTS ${CTX_COLOR}${USED_PCT_INT}%\033[0m"

echo -e "$PARTS"
