#!/bin/bash
# Shared Claude Code and Codex PreToolUse policy for force pushes.
set -euo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

[[ "$cmd" == *"git push"* ]] || exit 0

deny() {
    printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Force pushes are allowed only with --force-with-lease on branches other than main/master; main and master are protected."}}'
    exit 0
}

# Remove the two permitted lease flags, then reject any remaining bare force
# flag wherever it appears in the command.
stripped=$(printf '%s' "$cmd" | sed -E 's/--force-with-lease(=[^[:space:]]*)?//g; s/--force-if-includes//g')
if printf '%s' "$stripped" | grep -qE '(^|[[:space:]])(--force|-f)([[:space:]]|$)'; then
    deny
fi

[[ "$cmd" =~ --force-with-lease ]] || exit 0

# Reject an explicitly named protected destination before considering the
# checked-out branch.
if printf '%s' "$cmd" | grep -qE '(^|[[:space:]:/])(main|master)([[:space:]]|$)'; then
    deny
fi

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
[[ "$branch" == "main" || "$branch" == "master" ]] && deny

printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"Safe --force-with-lease push from a non-protected branch."}}'
