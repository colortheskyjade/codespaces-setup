#!/bin/bash
# Claude Code statusline — model | effort | branch* | tokens | ctx% | $cost

input=$(cat)

# Model name (compact)
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"' | sed -E 's/Claude //i; s/ \(with .*\)//i; s/ /-/g; s/(.)/\L\1/g')

# Effort / reasoning level
EFFORT=$(echo "$input" | jq -r '.session.effortLevel // "high"')
case "$EFFORT" in
  low)   EFFORT_DISPLAY="\033[34mlo\033[0m" ;;
  medium) EFFORT_DISPLAY="\033[33mmed\033[0m" ;;
  high)  EFFORT_DISPLAY="\033[32mhi\033[0m" ;;
  xhigh) EFFORT_DISPLAY="\033[1;35mxhi\033[0m" ;;
  *)     EFFORT_DISPLAY="\033[37m${EFFORT}\033[0m" ;;
esac

# Git branch + dirty indicator
FULL_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
BRANCH=""
DIRTY=""
if git -C "$FULL_DIR" rev-parse --git-dir &>/dev/null; then
  GIT_STATUS=$(git -C "$FULL_DIR" --no-optional-locks status -b --porcelain=v2 2>/dev/null)
  BRANCH=$(echo "$GIT_STATUS" | grep '^# branch.head ' | cut -d' ' -f3)
  if echo "$GIT_STATUS" | grep -qE '^[12?] '; then
    DIRTY="*"
  fi
fi
DISPLAY_BRANCH="$BRANCH"
if (( ${#BRANCH} > 25 )); then
  DISPLAY_BRANCH="${BRANCH:0:22}..."
fi

# Token usage (compact)
TOKENS_IN=$(echo "$input" | jq -r '.session.tokenUsage.input // 0')
TOKENS_OUT=$(echo "$input" | jq -r '.session.tokenUsage.output // 0')
TOTAL_TOKENS=$((TOKENS_IN + TOKENS_OUT))
if [ "$TOTAL_TOKENS" -ge 1000000 ]; then
  TOKENS="$(awk "BEGIN{printf \"%.1fM\", $TOTAL_TOKENS/1000000}")"
elif [ "$TOTAL_TOKENS" -ge 1000 ]; then
  TOKENS="$(awk "BEGIN{printf \"%.1fk\", $TOTAL_TOKENS/1000}")"
else
  TOKENS="$TOTAL_TOKENS"
fi

# Context % with color coding
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
USED_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
USED_PCT_INT=${USED_PCT%.*}
[ -z "$USED_PCT_INT" ] && USED_PCT_INT=0

CTX_COLOR="\033[32m"  # green
if [ "$CONTEXT_SIZE" -gt 0 ] 2>/dev/null; then
  COMPACT_PCT=$(( (CONTEXT_SIZE - 33000) * 100 / CONTEXT_SIZE ))
  (( USED_PCT_INT >= COMPACT_PCT )) && CTX_COLOR="\033[1;31m"       # bold red
  (( USED_PCT_INT < COMPACT_PCT && USED_PCT_INT >= COMPACT_PCT - 10 )) && CTX_COLOR="\033[1;33m"  # bold yellow
  (( USED_PCT_INT >= 50 && USED_PCT_INT < COMPACT_PCT - 10 )) && CTX_COLOR="\033[33m"  # yellow
fi

# Cost
COST=$(echo "$input" | jq -r '.session.cost // 0 | . * 100 | floor | . / 100 | tostring | "$" + .')

# Assemble
PARTS="\033[1;36m${MODEL}\033[0m"
PARTS="$PARTS ${EFFORT_DISPLAY}"
[ -n "$BRANCH" ] && PARTS="$PARTS \033[33m${DISPLAY_BRANCH}\033[0m\033[31m${DIRTY}\033[0m"
PARTS="$PARTS \033[35m${TOKENS}\033[0m"
(( USED_PCT_INT > 0 )) && PARTS="$PARTS ${CTX_COLOR}${USED_PCT_INT}%\033[0m"
PARTS="$PARTS \033[1;32m${COST}\033[0m"

echo -e "$PARTS"
