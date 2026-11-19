# Global preferences

One file for every agent: link it to `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` and
`~/.config/opencode/AGENTS.md`. Only what an agent can't learn from the code; project files override it.
Run `/doctor prompt-audit` after a model upgrade to find lines it no longer needs.

## About me

- <your role, stack and goals in two lines>

## Working style

- Features: `spec` → `to-plan` → `execute-plan` (test first, `commit` per task) → `pr`. Small fixes skip straight to a failing test.
- Ask before committing, pushing or touching CI/CD config.
- Another agent's review is advice: check each point against the code before acting on it.
