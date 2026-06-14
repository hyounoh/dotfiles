#!/bin/bash
# Stop hook — after a PR was created in this session, force the wrap-up cycle
# before the session is allowed to stop:
#   1. CLAUDE.md sync   2. STAY on the feature branch (so the change can be
#      verified locally)   3. prune merged ([gone]) branches
# Correctness of the next task is already guaranteed by validate-branch.sh, which
# requires every new branch to be created from an up-to-date main — so there is no
# need to return to main here (doing so would break local verification of the PR).

INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active')

[ "$STOP_HOOK_ACTIVE" = "true" ] && exit 0
[ ! -f ~/.claude/.current-pr ] && exit 0

PR_URL=$(cat ~/.claude/.current-pr)
rm -f ~/.claude/.current-pr ~/.claude/.current-issue

jq -n --arg pr "$PR_URL" \
  '{"decision": "block", "reason": ("PR " + $pr + " was created. Before stopping, complete the wrap-up: (1) update CLAUDE.md if any new conventions or patterns were introduced, (2) STAY on the current feature branch — do NOT switch to main — so the change can still be verified locally (the branch was already created from an up-to-date main, so the next task will start clean regardless), (3) prune local branches whose remote is gone: git fetch -p, then delete every branch marked [gone] in git branch -vv (skip any with unpushed work and report them instead).")}'
