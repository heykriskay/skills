#!/usr/bin/env bash
#
# SessionEnd hook: drops entries older than 30 days from the command log that
# log-commands.sh writes, matching cleanupPeriodDays in settings.json.

set -Eeuo pipefail

log="$HOME/.claude/bash-commands.jsonl"
[[ -f $log ]] || exit 0
umask 077

# BSD date (macOS) first, then GNU date (Linux).
cutoff=$(date -v-30d '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -d '30 days ago' '+%Y-%m-%dT%H:%M:%S')
tmp=$(mktemp "$log.XXXXXX")
jq -c --arg cutoff "$cutoff" 'select(.timestamp >= $cutoff)' "$log" >"$tmp"
mv "$tmp" "$log"
