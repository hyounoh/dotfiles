#!/bin/bash

PROMPT=$(cat | jq -r '.prompt')
ISSUE_NUM=$(echo "$PROMPT" | grep -oP '#\K[0-9]+' | head -1)

[ -z "$ISSUE_NUM" ] && exit 0

ISSUE=$(gh issue view "$ISSUE_NUM" \
  --json number,title,body,labels,assignees 2>/dev/null)

[ -z "$ISSUE" ] && exit 0

echo "$ISSUE_NUM" > ~/.claude/.current-issue

jq -n --arg ctx "Issue #$ISSUE_NUM:\n$ISSUE" \
  '{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": $ctx}}'

