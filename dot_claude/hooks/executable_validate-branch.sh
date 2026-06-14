#!/bin/bash
# PreToolUse hook (matcher: Bash) — enforces the branch-creation workflow.
#
# Rules enforced when the command creates a branch (git checkout -b / git switch -c):
#   1. Naming  — issue-{N}-* when an issue is active (~/.claude/.current-issue),
#                otherwise a type prefix: feat/ fix/ refactor/ docs/ test/ chore/ hotfix/
#   2. Dirty   — block if tracked files have uncommitted changes; Claude must show
#                the user and ask (stash / commit / discard) before starting a task
#   3. Base    — new branches must start from an up-to-date default branch (main).
#                The self-updating compound `git checkout main && git pull && git
#                checkout -b ...` is allowed from anywhere; otherwise the current
#                branch must BE main and not behind origin/main (best-effort fetch).
#
# One-shot escape hatch (only when the user explicitly asks for a stacked branch):
#   touch ~/.claude/.skip-branch-validation

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

# Strip quoted spans first (commit messages, PR bodies) so example text like
# "git checkout -b ..." inside a quoted string can't false-trigger. Newlines are
# flattened so multi-line quoted bodies pair up. Best-effort: escaped quotes may
# confuse it, and a *quoted* branch name skips validation — acceptable tradeoffs.
CLEAN=$(printf '%s' "$COMMAND" | tr '\n' ' ' | sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")

# Self-filter: only act on actual branch-creation invocations — `git` at the start
# of the command or right after a shell separator (&&, ;, |). This catches compound
# commands while ignoring commands that merely contain the text in a string.
# NOTE: POSIX tools only (BSD grep/sed) — hooks do not get the interactive PATH.
echo "$CLEAN" | grep -qE '(^|&&|;|\|)[[:space:]]*git +(checkout +-b|switch +-c)' || exit 0

# One-shot escape hatch for intentional stacked branches
if [ -f ~/.claude/.skip-branch-validation ]; then
  rm -f ~/.claude/.skip-branch-validation
  exit 0
fi

[ -n "$CWD" ] && cd "$CWD" 2>/dev/null
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

block() { echo "$1" >&2; exit 2; }

BRANCH_NAME=$(echo "$CLEAN" | sed -nE 's/.*(checkout -b|switch -c) +([^ ;&|]+).*/\2/p' | head -1)
[ -z "$BRANCH_NAME" ] && exit 0  # unparseable — don't false-block

# --- 1. Naming ---
ISSUE_NUM=$(cat ~/.claude/.current-issue 2>/dev/null)
if [ -n "$ISSUE_NUM" ]; then
  echo "$BRANCH_NAME" | grep -q "issue-$ISSUE_NUM" || \
    block "Branch name must include issue number. Expected: issue-$ISSUE_NUM-{description}, got: $BRANCH_NAME"
else
  echo "$BRANCH_NAME" | grep -qE '^(feat|fix|refactor|docs|test|chore|hotfix)/' || \
    block "Branch name must start with a type prefix (feat/ fix/ refactor/ docs/ test/ chore/ hotfix/). Got: $BRANCH_NAME"
fi

# --- 2. Dirty worktree (tracked changes only; untracked files are fine) ---
if [ -n "$(git status --porcelain 2>/dev/null | grep -v '^??')" ]; then
  block "Uncommitted tracked changes exist. Do NOT create the branch yet — show the user 'git status' and a short diff summary, then ask whether to stash, commit, or discard before starting the new task."
fi

# --- 3. Base must be the up-to-date default branch ---
DEFAULT_BRANCH=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
[ -z "$DEFAULT_BRANCH" ] && DEFAULT_BRANCH=main

# The recommended compound moves to the default branch and pulls before branching —
# allow it regardless of where we are now.
if echo "$CLEAN" | grep -qE "git +(checkout|switch) +$DEFAULT_BRANCH .*&&.*git +pull.*&&.*git +(checkout +-b|switch +-c)"; then
  exit 0
fi

CURRENT=$(git symbolic-ref --short HEAD 2>/dev/null)
[ "$CURRENT" = "$DEFAULT_BRANCH" ] || \
  block "Current branch is '$CURRENT', not '$DEFAULT_BRANCH'. New tasks must branch from the latest $DEFAULT_BRANCH. Run: git checkout $DEFAULT_BRANCH && git pull && git checkout -b $BRANCH_NAME"

# Best-effort freshness check (skip silently when offline)
git fetch origin "$DEFAULT_BRANCH" --quiet 2>/dev/null
BEHIND=$(git rev-list --count "HEAD..origin/$DEFAULT_BRANCH" 2>/dev/null || echo 0)
if [ "${BEHIND:-0}" -gt 0 ]; then
  block "Local $DEFAULT_BRANCH is $BEHIND commit(s) behind origin/$DEFAULT_BRANCH. Run 'git pull' first, then create the branch."
fi

exit 0
