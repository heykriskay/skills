#!/usr/bin/env bash
#
# Test hook. Failures go back to Claude with exit 2 (exit 1 wouldn't block).
#   verify.sh touched   TaskCompleted: tests for the files changed so far
#   verify.sh full      Stop: the whole suite (default)
#
# The suite command is detected per language, or set it yourself:
#   $CLAUDE_VERIFY_CMD, or the first line of .claude/verify in the project.
#   Go: go test ./...   Java: ./mvnw, mvn, ./gradlew or gradle test
#   Python: pytest      TS/JS: the package manager's `test` script
# No git repo, no changes or no test setup: does nothing.
# A failing Stop keeps sending Claude back until the suite passes; Claude Code
# caps that at 8 blocks in a row (CLAUDE_CODE_STOP_HOOK_BLOCK_CAP).

set -uo pipefail

mode=${1:-full}
input=$(cat)

dir=$(jq -r '.cwd // empty' <<<"$input")
cd "${CLAUDE_PROJECT_DIR:-${dir:-$PWD}}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
cd "$(git rev-parse --show-toplevel)" || exit 0

mapfile -t changed < <({ git diff --name-only HEAD; git ls-files --others --exclude-standard; } 2>/dev/null | sort -u)
((${#changed[@]})) || exit 0

has() { command -v "$1" >/dev/null; }
pm() { # package manager for this repo
  if [[ -f pnpm-lock.yaml ]]; then echo pnpm
  elif [[ -f yarn.lock ]]; then echo yarn
  elif [[ -f bun.lockb || -f bun.lock ]]; then echo bun
  else echo npm; fi
}
has_dep() { [[ -f package.json ]] && jq -e --arg d "$1" '(.dependencies // {}) + (.devDependencies // {}) | has($d)' package.json >/dev/null; }
mvn_cmd() { if [[ -x mvnw ]]; then echo ./mvnw; else echo mvn; fi; }
gradle_cmd() { if [[ -x gradlew ]]; then echo ./gradlew; else echo gradle; fi; }

cmds=()
full_cmds() {
  local c=${CLAUDE_VERIFY_CMD:-}
  [[ -z $c && -f .claude/verify ]] && c=$(head -n 1 .claude/verify)
  if [[ -n $c ]]; then cmds+=("$c"); return; fi
  [[ -f go.mod ]] && cmds+=("go test ./...")
  [[ -f pom.xml ]] && cmds+=("$(mvn_cmd) -q test")
  [[ -f build.gradle || -f build.gradle.kts ]] && cmds+=("$(gradle_cmd) test -q")
  if [[ -f pyproject.toml || -f pytest.ini || -f setup.cfg || -f tox.ini ]] && has pytest; then cmds+=("pytest -q"); fi
  if [[ -f package.json ]] && jq -e '.scripts.test' package.json >/dev/null; then cmds+=("$(pm) test --silent"); fi
}

touched_cmds() {
  local f stem pkgs=() py=() js=() java=()
  for f in "${changed[@]}"; do
    [[ -e $f ]] || continue
    case "$f" in
      *.go) pkgs+=("./$(dirname "$f")") ;;
      *.py)
        stem=$(basename "$f" .py)
        if [[ $stem == test_* || $stem == *_test ]]; then py+=("$f")
        else mapfile -t -O "${#py[@]}" py < <(git ls-files "*test_${stem}.py" "*${stem}_test.py"); fi ;;
      *.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs) js+=("$f") ;;
      *.java) stem=$(basename "$f" .java); [[ $stem == *Test ]] && java+=("$stem") || java+=("${stem}Test") ;;
    esac
  done
  if ((${#pkgs[@]})); then cmds+=("go test $(printf '%s\n' "${pkgs[@]}" | sort -u | tr '\n' ' ')"); fi
  if ((${#py[@]})) && has pytest; then cmds+=("pytest -q $(printf '%q ' "${py[@]}")"); fi
  if ((${#js[@]})); then
    if has_dep vitest; then cmds+=("npx vitest related --run $(printf '%q ' "${js[@]}")")
    elif has_dep jest; then cmds+=("npx jest --findRelatedTests $(printf '%q ' "${js[@]}")"); fi
  fi
  if ((${#java[@]})); then
    local list
    list=$(printf '%s\n' "${java[@]}" | sort -u | paste -sd, -)
    if [[ -f pom.xml ]]; then cmds+=("$(mvn_cmd) -q test -Dtest=$list -Dsurefire.failIfNoSpecifiedTests=false")
    elif [[ -f build.gradle || -f build.gradle.kts ]]; then cmds+=("$(gradle_cmd) test -q $(printf -- '--tests *%s ' "${java[@]}")"); fi
  fi
}

if [[ $mode == touched ]]; then touched_cmds; else full_cmds; fi
((${#cmds[@]})) || exit 0

# Stop runs after every turn: skip if this exact tree already passed.
if [[ $mode == full ]]; then
  state=$({ git diff HEAD; printf '%s\n' "${changed[@]}"; } | git hash-object --stdin)
  stamp="${TMPDIR:-/tmp}/claude-verify-$(pwd | git hash-object --stdin)"
  [[ -f $stamp && $(cat "$stamp") == "$state" ]] && exit 0
fi

for c in "${cmds[@]}"; do
  if ! out=$(bash -c "$c" 2>&1); then
    printf 'Tests failed (%s): `%s`\n%s\n' "$mode" "$c" "$(tail -n 60 <<<"$out")" >&2
    exit 2
  fi
done

[[ $mode == full ]] && printf '%s' "$state" >"$stamp"
exit 0
