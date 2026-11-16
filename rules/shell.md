---
paths:
  - "**/*.{sh,bash}"
---

# Shell scripts

- Bash, not POSIX sh: `#!/usr/bin/env bash`, then `set -Eeuo pipefail` for scripts that do work.
- Quote every expansion (`"$var"`, `"$@"`); use `[[ ]]` for tests and `$(...)` for substitution.
- Use `local` for function variables.
- Check that a command exists with `command -v`, not `which`.
- Stay portable between GNU (Linux) and BSD (macOS) tools: no bare `sed -i`, no GNU-only flags.
- After editing, the lint hook runs `shellcheck`. Fix what it reports, or add a `# shellcheck disable=SCxxxx` comment that says why.
