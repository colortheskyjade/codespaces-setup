#!/bin/bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC1091
# Claude Code statusline — simple one-line layout
# Shows: [model] 💻 environment 🌿 branch* 📊 context%
# Sources lib/core.sh and lib/git.sh for width-aware rendering

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Read JSON input
# shellcheck disable=SC2034  # consumed by lib/session.sh
input=$(cat)

# Source shared libraries
# shellcheck source=lib/core.sh
source "$SCRIPT_DIR/lib/core.sh"
# shellcheck source=lib/session.sh
source "$SCRIPT_DIR/lib/session.sh"
# shellcheck source=lib/git.sh
source "$SCRIPT_DIR/lib/git.sh"

# MARK: - Build Parts

# Model — shortened: "Claude Opus 4 (with extended thinking)" → "opus-4"
SHORT_MODEL=$(echo "$MODEL" | sed -E '
    s/Claude //i;
    s/ \(with extended thinking\)//i;
    s/ \(with .*\)//i;
    s/ /-/g;
    s/(.)/\L\1/g;
')
MODEL_PART="\033[36m[${SHORT_MODEL}]\033[0m"

# Environment
ENV_PART=""
if [ -n "$FRIENDLY_NAME" ]; then
    ENV_PART="💻 \033[35m${FRIENDLY_NAME}\033[0m"
fi

# Branch + dirty
BRANCH_PART=""
if [ -n "$BRANCH" ]; then
    DISPLAY_BRANCH=$(truncate_string "$BRANCH" 25)
    BRANCH_PART="🌿 \033[33m${DISPLAY_BRANCH}\033[0m\033[31m${DIRTY}\033[0m"
fi

# Context percentage
CONTEXT_PART=""
if (( USED_PCT_INT > 0 )); then
    CONTEXT_PART="${CTX_COLOR}${USED_PCT_INT}%\033[0m"
fi

# MARK: - Assemble Output (single line)
# Priority order (lowest priority dropped first on narrow terminals):
# 1. Branch+dirty (always)  2. Context% (always)  3. Machine (dropped on narrow)  4. Model (dropped first)

TERM_WIDTH=$(get_terminal_width)

LINE=$(fit_to_width "$TERM_WIDTH" 0 \
    "$(echo -e "$MODEL_PART")" \
    "$(echo -e "$ENV_PART")" \
    "$(echo -e "$BRANCH_PART")" \
    "$(echo -e "$CONTEXT_PART")")

printf '%s\n' "$LINE"
