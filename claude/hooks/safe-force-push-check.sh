#!/bin/bash
# PreToolUse hook (Bash matcher, filtered to `git push*` via the hook's `if`).
#
# Auto-allows `git push --force-with-lease` (optionally combined with
# --force-if-includes) when the target branch is under feature/* and is not
# main/master, and no bare --force/-f flag is also present. Everything else
# (bare --force, -f, or force-with-lease targeting main/master) falls through
# with no output, leaving it to the normal ask/deny permission rules.
set -euo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

[[ "$cmd" == *"git push"* ]] || exit 0
[[ "$cmd" =~ --force-with-lease ]] || exit 0

# Bail if a bare --force or -f flag rides along (only -with-lease/-if-includes allowed)
stripped=$(printf '%s' "$cmd" | sed -E 's/--force-with-lease(=[^[:space:]]*)?//g; s/--force-if-includes//g')
if printf '%s' "$stripped" | grep -qE '(^|[[:space:]])(--force|-f)([[:space:]]|$)'; then
  exit 0
fi

# Determine the target branch: explicit refspec positional arg if present,
# else the currently checked-out branch (force-with-lease pushes HEAD by default).
positional=$(printf '%s' "$cmd" | sed -E 's/^.*git push[[:space:]]*//; s/--[a-zA-Z-]+(=[^[:space:]]+)?//g; s/(^|[[:space:]])-[a-zA-Z]([[:space:]]|$)/ /g')
read -ra args <<< "$positional"

branch=""
if [[ ${#args[@]} -ge 2 ]]; then
  refspec="${args[1]}"
  branch="${refspec##*:}"
fi

if [[ -z "$branch" ]]; then
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
fi

if [[ "$branch" == feature/* && "$branch" != "main" && "$branch" != "master" ]]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"Safe force push (--force-with-lease, no bare --force) to feature branch %s"}}' "$branch"
fi
exit 0
