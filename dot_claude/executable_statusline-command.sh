#!/usr/bin/env bash
# Claude Code status line — mirrors Starship config style
# Receives JSON via stdin

input=$(cat)

# --- directory (truncate to 4 path segments, similar to Starship truncation_length=4) ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
home="$HOME"
cwd_display="${cwd/#$home/~}"
# keep last 4 segments
truncated=$(echo "$cwd_display" | awk -F'/' '{
  n = split($0, a, "/");
  if (n <= 5) { print $0 }
  else {
    out = "";
    for (i = n-3; i <= n; i++) out = out "/" a[i];
    print "…" out
  }
}')

# --- git branch & status ---
branch=""
git_status_str=""
git_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty')
if [ -n "$git_dir" ] && git -C "$git_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$git_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$git_dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi

  # build status flags
  flags=""
  gitstatus=$(git -C "$git_dir" --no-optional-locks status --porcelain 2>/dev/null)
  staged=$(echo "$gitstatus" | grep -c '^[MADRC]')
  modified=$(echo "$gitstatus" | grep -c '^.[MD]')
  untracked=$(echo "$gitstatus" | grep -c '^??')
  ahead=$(git -C "$git_dir" --no-optional-locks rev-list @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')
  behind=$(git -C "$git_dir" --no-optional-locks rev-list HEAD..@{u} 2>/dev/null | wc -l | tr -d ' ')

  [ "$staged" -gt 0 ]    && flags="${flags}+"
  [ "$modified" -gt 0 ]  && flags="${flags}!"
  [ "$untracked" -gt 0 ] && flags="${flags}?"
  [ "$ahead" -gt 0 ]     && flags="${flags}⇡${ahead}"
  [ "$behind" -gt 0 ]    && flags="${flags}⇣${behind}"

  if [ -n "$flags" ]; then
    git_status_str=" [${flags}]"
  fi
fi

# --- model ---
model=$(echo "$input" | jq -r '.model.display_name // empty')

# --- context usage ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- assemble ---
parts=""

# directory (cyan)
parts=$(printf '\033[36m%s\033[0m' "$truncated")

# git branch + status (yellow branch, dim status)
if [ -n "$branch" ]; then
  parts="${parts} $(printf '\033[33m \033[0m\033[33m%s\033[0m' "$branch")$(printf '\033[2m%s\033[0m' "$git_status_str")"
fi

# model (dim)
if [ -n "$model" ]; then
  parts="${parts} $(printf '\033[2m%s\033[0m' "$model")"
fi

# context usage
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 75 ]; then
    parts="${parts} $(printf '\033[31mctx:%s%%\033[0m' "$used_int")"
  elif [ "$used_int" -ge 50 ]; then
    parts="${parts} $(printf '\033[33mctx:%s%%\033[0m' "$used_int")"
  else
    parts="${parts} $(printf '\033[2mctx:%s%%\033[0m' "$used_int")"
  fi
fi

printf '%s' "$parts"
