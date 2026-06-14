#!/bin/bash
# UserPromptSubmit hook — when the prompt references a GitHub issue (#123),
# fetch it and inject it as context; remember the number for branch validation.
# NOTE: POSIX tools only (BSD grep/sed) — hooks do not get the interactive PATH.

PROMPT=$(cat | jq -r '.prompt')
ISSUE_NUM=$(echo "$PROMPT" | sed -nE 's/.*#([0-9]+).*/\1/p' | head -1)

[ -z "$ISSUE_NUM" ] && exit 0

ISSUE=$(gh issue view "$ISSUE_NUM" \
  --json number,title,body,labels,assignees 2>/dev/null)

[ -z "$ISSUE" ] && exit 0

echo "$ISSUE_NUM" > ~/.claude/.current-issue

jq -n --arg ctx "Issue #$ISSUE_NUM:\n$ISSUE" \
  '{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": $ctx}}'
