#!/usr/bin/env bash
#
# Stop hook: when Claude finishes a turn that changed code, run the project's
# check command and send failures back (exit 2), so Claude fixes them before
# handing the turn back. This replaces "verify before you say done" prompts.
#
# The command comes from, in order:
#   1. $CLAUDE_VERIFY_CMD
#   2. the first line of .claude/verify in the project (e.g. `npm test --silent`)
# No command, no git repo or no changes since the last pass: does nothing.
#
# Loop safety: skips when Claude is already continuing because of a Stop hook
# (stop_hook_active), and Claude Code caps consecutive blocks at 8.

set -uo pipefail

input=$(cat)
[[ $(jq -r '.stop_hook_active // false' <<<"$input") == true ]] && exit 0

dir=$(jq -r '.cwd // empty' <<<"$input")
dir=${CLAUDE_PROJECT_DIR:-${dir:-$PWD}}
cd "$dir" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

cmd=${CLAUDE_VERIFY_CMD:-}
[[ -z $cmd && -f .claude/verify ]] && cmd=$(head -n 1 .claude/verify)
[[ -z $cmd ]] && exit 0

# Fingerprint of the working tree; skip if it already passed in this state.
state=$({ git diff HEAD; git ls-files --others --exclude-standard; } 2>/dev/null | git hash-object --stdin)
[[ $state == "$(git hash-object --stdin </dev/null)" ]] && exit 0 # nothing changed
stamp="${TMPDIR:-/tmp}/claude-verify-$(printf '%s' "$dir" | git hash-object --stdin)"
[[ -f $stamp && $(cat "$stamp") == "$state" ]] && exit 0

if out=$(bash -c "$cmd" 2>&1); then
  printf '%s' "$state" >"$stamp"
  exit 0
fi

printf 'Verify failed: `%s`\n%s\n' "$cmd" "$(tail -n 60 <<<"$out")" >&2
exit 2
