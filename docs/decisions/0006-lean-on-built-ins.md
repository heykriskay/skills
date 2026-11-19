# 0006: Every step out of the loop gets a replacement

- **Status:** Accepted
- **Date:** 2026-11-19
- **Supersedes:** [0003](0003-adapt-upstream-skills.md); amends [0001](0001-approval-gates.md), [0002](0002-test-first.md) and [0005](0005-orchestration-is-opt-in.md)

## Context

The 1.0 skills were written for models that needed process spelled out: interview, spec, plan, test
first, verify, debug by method, review. By late 2026 Claude Code ships most of that as built-ins
(plan mode, `/goal`, `/code-review`, `/simplify`, `/verify`, `/batch`, background subagents in
worktrees), and Anthropic's own guidance says emphatic process instructions now make results worse:
Claude over-applies them and does extra work. Its rule is to write down only what Claude can't learn
from the code, and to move must-hold rules into hooks, deny rules or the sandbox.
The research is in [docs/research](../research/modern-claude-code-setup-2026.md).

## Decision

Following Lydia Hallie's "Rethinking Claude Code Best Practices" talk, each thing I used to do in the loop
moves to something that does it without me:

- **Steering → the model.** Instructions say only what Claude can't infer. The spec → plan → TDD → commit
  → PR skills stay as my process, slimmed; `/doctor prompt-audit` runs after model upgrades.
- **Approving → auto mode.** Trusted infrastructure is described in `autoMode.environment`.
- **Saying no → deny rules and the sandbox.** A deny rule only where a mistake can't be taken back; the
  sandbox stops what an approved command's code does once it runs. Projects commit their own rules.
- **Checking → hooks and CI.** Lint on edit, touched tests on task completion, the full suite on stop, all
  exiting 2; CI runs the same checks on every PR.
- Herdr orchestration (0005) moves to its own optional plugin.

## Consequences

- Instructions shrink from about 1,500 to about 400 lines; checks that must run no longer depend on Claude
  remembering them.
- "Test first" stays a skill, not a guarantee; the hooks guarantee the tests pass.
- Stop runs the suite after every turn that changed code, which costs time on slow suites; it skips
  unchanged trees.
- Four 1.0 skills are gone; the changelog maps each to its replacement.
