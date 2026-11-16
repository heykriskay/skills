# Global preferences

These apply across all projects. Project-level CLAUDE.md files can override anything here.

## About me

- <your role, stack and goals in two lines>

## Working style

- Ask before touching CI/CD config (GitHub Actions, pipelines).
- Follow the skills in `~/.claude/skills/`; they chain themselves. Ending a session with work left: suggest `/handoff`.
- Feature requests and assignments: run `grilling` first, then the chain; specs and plans go in `specs/`.

## Herdr (only if `HC_TERMINAL_ID` is set)

- Run slow commands (test suites, builds, CI watches, installs) as `hc run --bg --rm --no-notify --name <n> -- <cmd>` and then `hc wait <n>`, so you stay reachable for helper reports.

## Token budget

- Do the work in this session by default; it's faster and far cheaper than helpers. Start helpers or subagents only when a skill calls for them or I ask, and say first in one line how many, which template/model and why.
- Research: search in this session first; at most one `Explore` (haiku) helper unless I ask for more.
- Most helpers are read-only (`Explore`, `reviewer`); at most 2 writing workers at once, one per worktree unless I OK two. Use opus only for architecture or security reviews.
- Remove helpers as soon as their report is read.
