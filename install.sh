#!/usr/bin/env bash
#
# Copies skills, agents, rules, hooks and the status line into a Claude config dir.
# Usage: ./install.sh [--herdr] [--codex] [target]   (default: ~/.claude)
#   --herdr  also install the optional Herdr skills and agents (plugins/herdr)
#   --codex  also link each skill into ~/.agents/skills, where Codex looks
#            (OpenCode already reads ~/.claude/skills)
# Never touches settings.json or CLAUDE.md; merge those from examples/ by hand.

set -Eeuo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
herdr=0 codex=0
while [[ ${1:-} == --* ]]; do
  case $1 in
    --herdr) herdr=1 ;;
    --codex) codex=1 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done
dest="${1:-$HOME/.claude}"

mkdir -p "$dest"
for dir in skills agents rules hooks; do
  mkdir -p "$dest/$dir"
  cp -R "$src/$dir/." "$dest/$dir/"
  echo "installed $dir/ -> $dest/$dir"
done
if ((herdr)); then
  cp -R "$src/plugins/herdr/skills/." "$dest/skills/"
  cp -R "$src/plugins/herdr/agents/." "$dest/agents/"
  echo "installed Herdr skills and agents"
fi
if ((codex)); then
  mkdir -p "$HOME/.agents/skills"
  for skill in "$dest/skills/"*/; do
    ln -sfn "${skill%/}" "$HOME/.agents/skills/$(basename "$skill")"
  done
  echo "linked skills into ~/.agents/skills for Codex"
fi
cp "$src/statusline.sh" "$dest/statusline.sh"
chmod +x "$dest/hooks/"*.sh "$dest/statusline.sh"
echo "installed statusline.sh"

command -v jq >/dev/null || echo "warning: jq not found; hooks and status line need it" >&2
echo "Done. Merge examples/settings.json into $dest/settings.json to enable hooks and the status line."
echo "Optional: add a .claude/verify file with your test command to each project."
