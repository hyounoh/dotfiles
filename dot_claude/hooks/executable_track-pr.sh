#!/bin/bash

INPUT=$(cat)
PR_URL=$(echo "$INPUT" | jq -r '.tool_response.stdout // ""' | grep -oP 'https://github\.com\S+')

[ -z "$PR_URL" ] && exit 0

echo "$PR_URL" > ~/.claude/.current-pr

