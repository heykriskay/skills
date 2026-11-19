---
paths:
  - "**/*.{sh,bash}"
---

# Shell scripts

- Bash, not POSIX sh: `#!/usr/bin/env bash`, then `set -Eeuo pipefail` for scripts that do work.
- Stay portable between GNU (Linux) and BSD (macOS) tools: no bare `sed -i`, no GNU-only flags.
- Silence a shellcheck finding only with a `# shellcheck disable=SCxxxx` comment that says why.
