#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')
BRANCH_NAME=$(echo "$COMMAND" | grep -oP '(?<=checkout -b |switch -c )\S+')
ISSUE_NUM=$(cat ~/.claude/.current-issue 2>/dev/null)

[ -z "$ISSUE_NUM" ] && exit 0

if ! echo "$BRANCH_NAME" | grep -q "issue-$ISSUE_NUM"; then
  echo "Branch name must include issue number. Expected: issue-$ISSUE_NUM-{description}, got: $BRANCH_NAME" >&2
  exit 2
fi

exit 0

