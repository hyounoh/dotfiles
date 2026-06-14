#!/bin/bash
# PostToolUse hook (matcher: Bash) — records the PR URL whenever a command that
# invokes `gh pr create` succeeds, so the Stop hook can enforce the wrap-up cycle.
# Self-filters (instead of an `if` prefix match) so compound commands like
# `git push ... && gh pr create ...` are caught too.
# NOTE: POSIX tools only (BSD grep/sed) — hooks do not get the interactive PATH.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

echo "$COMMAND" | grep -qE '(^|&&|;|\|)[[:space:]]*gh +pr +create' || exit 0

PR_URL=$(echo "$INPUT" | jq -r '.tool_response.stdout // ""' \
  | grep -oE 'https://github\.com/[^[:space:]]+/pull/[0-9]+' | head -1)

[ -z "$PR_URL" ] && exit 0

echo "$PR_URL" > ~/.claude/.current-pr
