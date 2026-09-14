#!/bin/bash
# Integration checks use only disposable repositories and local remotes.
set -euo pipefail

script=$(cd "$(dirname "$0")/.." && pwd)/agents/hooks/git-session-sync.sh
fixture_root=$(mktemp -d)
trap 'rm -r "$fixture_root"' EXIT
unset GIT_DIR GIT_WORK_TREE GIT_COMMON_DIR GIT_INDEX_FILE GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME='Sync Test' GIT_AUTHOR_EMAIL=sync-test@example.invalid
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME" GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
fixture_count=0
checks=0

gitq() {
    git "$@" >"$fixture_root/git.log" 2>&1 || { cat "$fixture_root/git.log"; return 1; }
}

new_repo() {
    fixture_count=$((fixture_count + 1))
    fixture="$fixture_root/case $fixture_count"
    seed="$fixture/seed"
    checkout="$fixture/checkout with spaces"
    mkdir -p "$fixture"
    gitq init --bare --initial-branch=main "$fixture/remote.git"
    gitq init --initial-branch=main "$seed"
    printf 'initial\n' > "$seed/tracked.txt"
    printf 'ignored.txt\n' > "$seed/.gitignore"
    gitq -C "$seed" add .
    gitq -C "$seed" commit -m 'Add initial files'
    gitq -C "$seed" remote add origin "$fixture/remote.git"
    gitq -C "$seed" push -u origin main
    gitq clone "$fixture/remote.git" "$checkout"
    initial=$(git -C "$checkout" rev-parse HEAD)
}

advance_remote() {
    printf 'remote change\n' >> "$seed/remote.txt"
    gitq -C "$seed" add .
    gitq -C "$seed" commit -m 'Advance remote'
    gitq -C "$seed" push
    target=$(git -C "$seed" rev-parse HEAD)
}

run_hook() {
    output=$(jq -cn --arg cwd "$1" --arg source "${2:-startup}" \
        '{hook_event_name: "SessionStart", cwd: $cwd, source: $source}' | "$script")
    context=$(jq -er '.hookSpecificOutput | select(.hookEventName == "SessionStart") | .additionalContext' <<< "$output")
}

expect_context() {
    [[ "$context" == *"$1"* ]] || { printf 'Unexpected hook result: %s\n' "$context"; exit 1; }
}

unchanged() {
    [[ $(git -C "$checkout" rev-parse HEAD) == "$initial" ]]
}

passed() {
    checks=$((checks + 1))
    printf 'ok %d - %s\n' "$checks" "$1"
}

new_repo
gitq -C "$seed" push origin HEAD:obsolete
gitq -C "$checkout" fetch
gitq -C "$seed" push origin --delete obsolete
gitq -C "$checkout" tag local-only
gitq -C "$checkout" config fetch.pruneTags true
gitq -C "$checkout" config remote.origin.pruneTags true
mkdir -p "$fixture/hooks" "$checkout/nested directory"
printf '#!/bin/bash\ntouch "%s"\n' "$fixture/merge-hook-ran" > "$fixture/hooks/post-merge"
chmod +x "$fixture/hooks/post-merge"
gitq -C "$checkout" config core.hooksPath "$fixture/hooks"
advance_remote
run_hook "$checkout/nested directory"
expect_context 'fast-forwarded main'
[[ $(git -C "$checkout" rev-parse HEAD) == "$target" ]]
[[ $(git -C "$checkout" show-ref refs/remotes/origin/obsolete || true) == '' ]]
gitq -C "$checkout" show-ref refs/tags/local-only
[[ ! -e "$fixture/merge-hook-ran" ]]
run_hook "$checkout" resume
expect_context 'up to date'
passed 'nested session cwd, fast-forward, pruning, local tags, and no Git merge hook'

for kind in unstaged staged untracked; do
    new_repo
    advance_remote
    case "$kind" in
        unstaged) printf 'local\n' >> "$checkout/tracked.txt" ;;
        staged) printf 'local\n' >> "$checkout/tracked.txt"; gitq -C "$checkout" add . ;;
        untracked) printf 'local\n' > "$checkout/new.txt" ;;
    esac
    gitq -C "$checkout" config merge.autostash true
    before=$(git -C "$checkout" status --porcelain)
    run_hook "$checkout"
    expect_context 'local changes or untracked files'
    unchanged
    [[ $(git -C "$checkout" status --porcelain) == "$before" ]]
    [[ $(git -C "$checkout" rev-parse origin/main) == "$target" ]]
    [[ $(git -C "$checkout" stash list) == '' ]]
    passed "fetch without changing $kind work"
done

new_repo
printf 'local commit\n' >> "$checkout/tracked.txt"
gitq -C "$checkout" commit -am 'Add local work'
initial=$(git -C "$checkout" rev-parse HEAD)
run_hook "$checkout"
expect_context 'local commits or has diverged'
unchanged
advance_remote
run_hook "$checkout"
expect_context 'local commits or has diverged'
unchanged
passed 'ahead and diverged branches retain local commits'

for kind in detached no-upstream; do
    new_repo
    advance_remote
    if [[ "$kind" == detached ]]; then
        gitq -C "$checkout" switch --detach
    else
        gitq -C "$checkout" switch -c feature/local
    fi
    run_hook "$checkout"
    if [[ "$kind" == detached ]]; then expect_context 'HEAD is detached'; else expect_context 'no available remote upstream'; fi
    unchanged
    passed "$kind checkout stays in place"
done

new_repo
linked="$fixture/linked worktree"
gitq -C "$checkout" worktree add -b feature/worktree "$linked" main
gitq -C "$linked" branch -u origin/main
advance_remote
run_hook "$linked" clear
expect_context 'fast-forwarded feature/worktree'
[[ $(git -C "$linked" rev-parse HEAD) == "$target" ]]
unchanged
passed 'linked worktree sync leaves the primary checkout untouched'

new_repo
advance_remote
printf '%s\n' "$initial" > "$checkout/.git/MERGE_HEAD"
run_hook "$checkout"
expect_context 'a Git operation is in progress'
unchanged
[[ $(cat "$checkout/.git/MERGE_HEAD") == "$initial" ]]
passed 'in-progress Git operation is preserved'

new_repo
advance_remote
gitq -C "$checkout" remote set-url origin "$fixture/unavailable.git"
run_hook "$checkout"
expect_context 'fetch failed'
unchanged
[[ "$context" != *unavailable.git* ]]
passed 'unavailable remote is nonblocking and does not leak its URL'

new_repo
printf 'remote file\n' > "$seed/ignored.txt"
gitq -C "$seed" add -f ignored.txt
advance_remote
printf 'local ignored file\n' > "$checkout/ignored.txt"
run_hook "$checkout"
expect_context 'fast-forward failed'
unchanged
[[ $(cat "$checkout/ignored.txt") == 'local ignored file' ]]
passed 'ignored files are never overwritten'

new_repo
advance_remote
output=$(jq -cn --arg cwd "$checkout" \
    '{hook_event_name: "SessionStart", source: "compact", cwd: $cwd}' | "$script")
[[ -z "$output" ]]
unchanged
[[ $(git -C "$checkout" rev-parse origin/main) == "$initial" ]]
[[ -z $("$script" --cwd "$fixture_root") ]]
output=$(printf 'invalid json' | "$script")
jq -e '.hookSpecificOutput.additionalContext | contains("invalid hook input")' <<< "$output" >/dev/null
passed 'compaction, non-repositories, and malformed input are safe'

output=$("$script" --cwd "$checkout")
jq -e '.hookSpecificOutput.additionalContext | contains("fast-forwarded")' <<< "$output" >/dev/null
passed 'direct invocation supports other agents'

new_repo
gitq -C "$seed" -c protocol.file.allow=always submodule add "$fixture/remote.git" module
advance_remote
gitq -C "$checkout" pull --ff-only
gitq -C "$checkout" -c protocol.file.allow=always submodule update --init
initial=$(git -C "$checkout" rev-parse HEAD)
advance_remote
printf 'local submodule work\n' >> "$checkout/module/tracked.txt"
run_hook "$checkout"
expect_context 'local changes or untracked files'
unchanged
[[ $(tail -n 1 "$checkout/module/tracked.txt") == 'local submodule work' ]]
passed 'dirty submodule work is preserved'

gitq init --initial-branch=main "$fixture/unborn"
run_hook "$fixture/unborn"
expect_context 'no remotes'
gitq -C "$fixture/unborn" remote add origin "$fixture/remote.git"
run_hook "$fixture/unborn"
expect_context 'the branch has no commits'
[[ -z $(git -C "$fixture/unborn" rev-parse --verify HEAD 2>/dev/null || true) ]]
passed 'repositories without remotes or commits are safe'

printf 'Passed %d integration checks.\n' "$checks"
