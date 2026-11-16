# 0001: You approve the spec, the plan and every commit

- **Status:** Accepted
- **Date:** 2026-11-16

## Context

An agent that runs from idea to merged code on its own is fast, but when it misunderstands the idea,
the mistake is found late and costs a lot to undo. Most wrong turns happen at the start: the wrong
problem, the wrong scope, the wrong design.

## Decision

The workflow stops for a human OK at three points: after the spec (`to-spec`), after the plan
(`to-plan`) and before each commit (`commit`). Between those points Claude keeps going without asking
"should I continue?", and writes small judgment calls down as rulings to check afterwards.

## Consequences

- Mistakes are caught while they are cheap: a sentence in a spec, not a day of code.
- You stay in charge of what lands in git history.
- It is slower than a fully autonomous run, and needs you nearby at the gates.
