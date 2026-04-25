#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

if ! echo "$COMMAND" | grep -qE 'npm test|jest|pytest|eslint|lint'; then
  exit 0
fi

jq -n '{"decision": "block", "reason": "Tests or lint failed. Fix all failures before creating a PR."}'

