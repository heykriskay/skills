#!/usr/bin/env bash
#
# PostToolUse hook for Edit/Write: lints the edited file and sends problems
# back to Claude (exit 2). Linters that aren't installed are skipped. Only
# warnings and errors count: style notes would fire on every edit to old files.
#   *.sh            shellcheck
#   *.yaml, *.yml   yamllint

f=$(jq -r '.tool_input.file_path // empty')
[[ -f $f ]] || exit 0

has() { command -v "$1" >/dev/null; }
out=""

case "$f" in
  *.sh | *.bash)
    has shellcheck && out+=$(shellcheck -S warning -f gcc "$f" 2>&1)
    ;;
  *.yaml | *.yml)
    has yamllint && out+=$(yamllint --no-warnings -f parsable -d relaxed "$f" 2>&1)
    ;;
esac

[[ -z $out ]] && exit 0
printf 'Lint problems in %s:\n%s\n' "$f" "$out" >&2
exit 2
