#!/bin/bash
# Shared session-start Git sync; also usable directly with --cwd "$PWD".
set -euo pipefail

report() {
    jq -cn --arg message "Git session sync: $*" \
        '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $message}}'
    exit 0
}

trap 'report "sync failed; inspect Git status before continuing."' ERR

if [[ $# -eq 2 && "$1" == --cwd ]]; then
    cwd=$2
elif [[ $# -eq 0 ]]; then
    input=$(cat)
    jq -e 'type == "object"' <<< "$input" >/dev/null 2>&1 || report "invalid hook input; skipped."
    event=$(jq -r '.hook_event_name // empty' <<< "$input")
    source=$(jq -r '.source // empty' <<< "$input")
    [[ "$event" == SessionStart ]] || exit 0
    case "$source" in startup|resume|clear) ;; *) exit 0 ;; esac
    cwd=$(jq -er '.cwd | select(type == "string")' <<< "$input") || report "missing session directory; skipped."
else
    report 'expected hook input or --cwd with an absolute directory; skipped.'
fi
[[ "$cwd" == /* && -d "$cwd" ]] || report "invalid session directory; skipped."

# Always select the session's repository, even if the caller has Git overrides.
unset GIT_DIR GIT_WORK_TREE GIT_COMMON_DIR GIT_INDEX_FILE
unset GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES
cd "$cwd"
[[ $(git rev-parse --is-inside-work-tree 2>/dev/null || true) == true ]] || exit 0
repo=$(git rev-parse --show-toplevel)
cd "$repo"
git_dir=$(git rev-parse --absolute-git-dir)
[[ -n $(git remote) ]] || report "no remotes; skipped."

# Avoid authentication prompts. Codex also enforces the hook's 30-second timeout.
export GIT_TERMINAL_PROMPT=0 GCM_INTERACTIVE=Never
export GIT_ASKPASS=/usr/bin/false SSH_ASKPASS=/usr/bin/false
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -oBatchMode=yes -oConnectTimeout=5}"

checkout_reason() {
    local marker status
    for marker in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply sequencer BISECT_START index.lock; do
        if [[ -e "$git_dir/$marker" ]]; then
            printf '%s' 'a Git operation is in progress'
            return
        fi
    done
    if ! status=$(git status --porcelain=v1 --untracked-files=all --ignore-submodules=none); then
        printf '%s' 'checkout status could not be read'
    elif [[ -n "$status" ]]; then
        printf '%s' 'the checkout has local changes or untracked files'
    fi
}

before_branch=$(git symbolic-ref --quiet HEAD 2>/dev/null || true)
before_head=$(git rev-parse --verify HEAD 2>/dev/null || true)
before_reason=$(checkout_reason)

# Keep raw Git output out of agent context: remote URLs can contain credentials.
if ! git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=10 \
    -c gc.auto=0 -c maintenance.auto=false fetch --all --prune \
    --no-prune-tags --no-recurse-submodules >/dev/null 2>&1; then
    report "fetch failed; the checked-out branch was not updated. Remote state may be stale."
fi

branch=$(git symbolic-ref --quiet HEAD 2>/dev/null || true)
head=$(git rev-parse --verify HEAD 2>/dev/null || true)
[[ "$branch" == "$before_branch" && "$head" == "$before_head" ]] || \
    report "fetched remotes; the checkout changed during fetch, so fast-forward was skipped."
reason=$(checkout_reason)
reason=${before_reason:-$reason}
[[ -z "$reason" ]] || report "fetched remotes; skipped fast-forward because $reason."
[[ -n "$branch" ]] || report "fetched remotes; HEAD is detached, so fast-forward was skipped."
[[ -n "$head" ]] || report "fetched remotes; the branch has no commits, so fast-forward was skipped."

upstream=$(git rev-parse --symbolic-full-name '@{upstream}' 2>/dev/null || true)
[[ "$upstream" == refs/remotes/* ]] || report "fetched remotes; this branch has no available remote upstream."
target=$(git rev-parse --verify "$upstream^{commit}")
label=${branch#refs/heads/}
tracking=${upstream#refs/remotes/}
[[ "$head" != "$target" ]] || report "fetched remotes; $label is up to date with $tracking."
git merge-base --is-ancestor "$head" "$target" || \
    report "fetched remotes; $label has local commits or has diverged from $tracking; left unchanged."

# No autostash, merge commits, ignored-file overwrites, or Git hook side effects.
if ! git -c core.hooksPath=/dev/null -c submodule.recurse=false merge \
    --ff-only --no-autostash --no-edit --no-stat --no-overwrite-ignore "$target" >/dev/null 2>&1; then
    report "fetched remotes; fast-forward failed. Inspect Git status before continuing."
fi
report "fetched remotes; fast-forwarded $label to $tracking (${target:0:12})."
