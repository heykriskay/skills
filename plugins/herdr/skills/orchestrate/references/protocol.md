# Worker protocol

## IDs

- **Task** `T<n>`: the plan task number. A small change without a plan is `T1`.
- **Attempt** `T<n>-a<k>`: one worker run on that task (a respawn is `T3-a2`). Briefs, reports, diff files and ledger lines carry it; a report for a non-current attempt is stale: log it, don't act on it.

## Brief checklist

`.orchestrate/<name>.md`, in this order:

1. **Attempt** and **objective**, plus spec/plan paths and the plan task.
2. **May edit** / **out of bounds** ("no commits, no sub-agents, no `hc run`").
3. **Smoke command**, run first; red smoke means `BLOCKED` with its output.
4. **Verify commands**, the full suite, must pass before `DONE`.
5. **Report:** full report at `.orchestrate/<attempt>-report.md`.
6. **Effort:** small (~10 tool calls) / medium / large.

Implementer briefs add "Leave changes uncommitted; the orchestrator commits after the user approves." Reviewer briefs add the spec, the implementer's brief and report, the diff file, the round, and "forward findings to `<feature>-impl`: yes" for rounds 1-2, "no" at the cap. Fix rounds append `## Fix round R` or `## Fix round R (user)`.

## Reports and questions

Workers send exactly one final line and `ASK` lines as defined in their agent files: `agents/implementer.md` (statuses `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, `FAILED`, plus `ASK`) and `agents/reviewer.md` (verdict line). Don't restate the format elsewhere.

## Review package

The orchestrator prepares one diff per review:

```bash
hc exec --cwd "<worktree>" sh -c 'git add -N . && git diff HEAD > .orchestrate/<attempt>-r<R>.diff'
```

The reviewer checks the implementer's report as claims, opens with `READY` or `NOT READY`, then criteria and findings `Critical / Important / Minor` (`file:line`, problem, fix). Test tampering is Important. Findings go to `.orchestrate/<attempt>-r<R>.md`; on `NOT READY` with "forward: yes" they go straight to the implementer.
