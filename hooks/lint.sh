#!/usr/bin/env bash
#
# PostToolUse hook for Edit/Write: lints the edited file and sends problems
# back to Claude (exit 2). Linters that aren't installed are skipped. Only
# warnings and errors count: style notes would fire on every edit to old files.
#   *.sh, *.bash        shellcheck
#   *.yaml, *.yml       yamllint
#   *.go                gofmt, then go vet on the file's package
#   *.py                ruff
#   *.ts, *.tsx, *.js…  the project's own eslint (node_modules/.bin)
# Java is left to the compiler in the test hooks.

f=$(jq -r '.tool_input.file_path // empty')
[[ -f $f ]] || exit 0

has() { command -v "$1" >/dev/null; }
root() { # nearest parent of the file that contains $1
  local d
  d=$(dirname "$f")
  while [[ $d != / && ! -e $d/$1 ]]; do d=$(dirname "$d"); done
  [[ -e $d/$1 ]] && printf '%s' "$d"
}
out=""

case "$f" in
  *.sh | *.bash)
    has shellcheck && out=$(shellcheck -S warning -f gcc "$f" 2>&1)
    ;;
  *.yaml | *.yml)
    has yamllint && out=$(yamllint --no-warnings -f parsable -d relaxed "$f" 2>&1)
    ;;
  *.go)
    if has gofmt; then
      out=$(gofmt -l -e "$f" 2>&1 | sed "s|^$f\$|$f: not gofmt-formatted (run gofmt -w)|")
      [[ -z $out ]] && has go && out=$(cd "$(dirname "$f")" && go vet . 2>&1)
    fi
    ;;
  *.py)
    has ruff && out=$(ruff check --quiet "$f" 2>&1)
    ;;
  *.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs)
    r=$(root node_modules/.bin/eslint)
    [[ -n $r ]] && out=$(cd "$r" && node_modules/.bin/eslint --quiet "$f" 2>&1)
    ;;
esac

[[ -z $out ]] && exit 0
printf 'Lint problems in %s:\n%s\n' "$f" "$out" >&2
exit 2
