# 0005: Multi-agent orchestration is optional

- **Status:** Accepted
- **Date:** 2026-11-16

## Context

Running separate implementer and reviewer agents gives a real second opinion and keeps the main
session's context small. It also costs 3 to 10 times more tokens and needs the Herdr terminal app.

## Decision

The core workflow runs in a single session. `orchestrate` and `hc` are an opt-in layer for larger
features, only used when Herdr is running, and `orchestrate` offers `execute-plan` instead when a
change touches fewer than about three files.

## Consequences

- Everyone can use the workflow without extra tools or extra cost.
- Big features can still get independent review.
- Two skills in the set don't work for people without Herdr. The README marks them optional.
