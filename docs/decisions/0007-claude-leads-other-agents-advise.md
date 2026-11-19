# 0007: Claude leads; other agents advise

- **Status:** Accepted
- **Date:** 2026-11-19

## Context

Codex and OpenCode are strong too, and all three now read `AGENTS.md`, Agent Skills and MCP. Running
several agents can catch more, but each extra agent costs many more tokens, and research on
cross-vendor review found it helps in one direction and hurts in the other when the reviewer's fixes
are applied blindly. The research is in [docs/research](../research/multi-agent-coding-setup-2026.md).

## Decision

- One source: `AGENTS.md` for instructions and Agent Skills for skills, so every agent works from the
  same rules. Each tool keeps its own safety config, mirrored from the Claude settings.
- Claude Code is the lead. Work leaves the session only through the `delegate` skill's table: cheap
  search, parallel batches, cloud sessions for long work, and Codex for second opinions and independent
  attempts, via OpenAI's official plugin.
- Another vendor's output is advice: Claude checks each point against the code before acting.

## Consequences

- Switching tools for a task needs no new setup; the rules, skills and checks come along.
- No automatic model router: the choice is made by a skill description and stays visible.
- Codex needs its own subscription or API key; without it, `delegate` falls back to Claude.
