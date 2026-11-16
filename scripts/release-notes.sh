#!/usr/bin/env bash
#
# Prints the CHANGELOG.md section for a version (default: the version in
# .claude-plugin/plugin.json). Exits 1 if the section is missing or empty.
# Usage: ./scripts/release-notes.sh [version]

set -Eeuo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="${1:-$(jq -r .version "$root/.claude-plugin/plugin.json")}"

notes=$(awk -v v="$version" '
  index($0, "## " v " ") == 1 || $0 == "## " v { found = 1; next }
  found && /^## / { exit }
  found { print }
' "$root/CHANGELOG.md" | sed '/./,$!d')

if [[ -z ${notes//[[:space:]]/} ]]; then
  printf 'CHANGELOG.md has no notes for version %s\n' "$version" >&2
  exit 1
fi
printf '%s\n' "$notes"
