#!/usr/bin/env bash
#
# Checks the repo the same way CI does. Run from anywhere: ./scripts/validate.sh
#   1. shellcheck on every shell script
#   2. every .json file parses
#   3. every skill and agent has frontmatter with a name and description,
#      and each skill's name matches its folder
#   4. `claude plugin validate --strict` (skipped if the claude CLI is missing)

set -Eeuo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

fail=0
error() { printf 'ERROR: %s\n' "$*" >&2; fail=1; }
step() { printf '\n== %s\n' "$*"; }

# Prints the value of a frontmatter key ("" if missing or no frontmatter).
field() {
  awk -v key="$2" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    NR > 1 && index($0, key ":") == 1 { sub("^" key ":[ ]*", ""); print; exit }
  ' "$1"
}

step "shellcheck"
if command -v shellcheck >/dev/null; then
  mapfile -t scripts < <(git ls-files '*.sh')
  shellcheck -S warning "${scripts[@]}" || fail=1
  printf '%d scripts checked\n' "${#scripts[@]}"
else
  echo "shellcheck not installed, skipped"
fi

step "JSON"
while IFS= read -r f; do
  jq empty "$f" 2>/dev/null || error "$f is not valid JSON"
done < <(git ls-files '*.json')
echo "done"

step "Skills"
for dir in skills/*/; do
  dir=${dir%/}
  name=$(basename "$dir")
  f="$dir/SKILL.md"
  [[ -f $f ]] || { error "$dir has no SKILL.md"; continue; }
  [[ $(field "$f" name) == "$name" ]] || error "$f: name must be '$name'"
  [[ -n $(field "$f" description) ]] || error "$f: description is missing"
  [[ $name =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || error "$f: folder name must be kebab-case"
  [[ -f $dir/README.md ]] && error "$dir: put docs in SKILL.md or references/, not README.md"
done
echo "$(find skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') skills checked"

step "Agents"
for f in agents/*.md; do
  [[ -n $(field "$f" name) ]] || error "$f: name is missing"
  [[ -n $(field "$f" description) ]] || error "$f: description is missing"
done
echo "done"

step "Plugin manifest"
if command -v claude >/dev/null; then
  claude plugin validate --strict . || fail=1
else
  echo "claude CLI not installed, skipped (npm i -g @anthropic-ai/claude-code)"
fi

if ((fail)); then
  printf '\nValidation failed.\n' >&2
  exit 1
fi
printf '\nAll checks passed.\n'
