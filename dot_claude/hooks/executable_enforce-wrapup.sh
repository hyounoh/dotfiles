#!/bin/bash

INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active')

[ "$STOP_HOOK_ACTIVE" = "true" ] && exit 0
[ ! -f ~/.claude/.current-pr ] && exit 0

PR_URL=$(cat ~/.claude/.current-pr)
rm -f ~/.claude/.current-pr ~/.claude/.current-issue

jq -n --arg pr "$PR_URL" \
  '{"decision": "block", "reason": ("PR " + $pr + " was created. Before stopping: (1) update CLAUDE.md if any new conventions were introduced, (2) run /compact.")}'

