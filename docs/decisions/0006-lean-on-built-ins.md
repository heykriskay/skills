# 0006: Lean on Claude Code's built-ins; enforce with hooks, not prompts

- **Status:** Accepted
- **Date:** 2026-11-19
- **Supersedes:** [0002](0002-test-first.md), [0003](0003-adapt-upstream-skills.md); amends [0001](0001-approval-gates.md) and [0005](0005-orchestration-is-opt-in.md)

## Context

The 1.0 skills were written for models that needed process spelled out: interview, spec, plan, test
first, verify, debug by method, review. By late 2026 Claude Code ships most of that as built-ins
(plan mode, `/goal`, `/code-review`, `/simplify`, `/verify`, `/batch`, background subagents in
worktrees), and Anthropic's own guidance says emphatic process instructions now make results worse:
Claude over-applies them and does extra work. Its rule is to write down only what Claude can't learn
from the code, and to move must-hold rules into hooks, deny rules or the sandbox.
The research is in [docs/research](../research/modern-claude-code-setup-2026.md).

## Decision

- Keep only skills that hold my own taste or knowledge Claude can't infer: `spec` and `pr`.
- Checks that must run are hooks: `lint.sh` on every edit, `verify.sh` when Claude stops after
  changing code. Both exit 2 so Claude has to fix the failure.
- Approval gates (0001) stay, but as one line in CLAUDE.md plus deny rules on `git push` and history
  rewrites, and plan-mode approval replaces the separate plan gate.
- Herdr orchestration (0005) moves to its own optional plugin, `kriskay-herdr`.
- Keep the `Explore` override on haiku: the built-in now runs on the main model.

## Consequences

- About 1,000 fewer lines of instructions loaded or available in every session.
- Upgrades to Claude Code's built-ins reach me without edits here.
- "Test first" is no longer forced. The verify hook makes sure tests pass, not that they were written
  first; ask for TDD in the prompt when it matters.
- 1.0 users lose the skill names they knew; the changelog maps each to its replacement.
