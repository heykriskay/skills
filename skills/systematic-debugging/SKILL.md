---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

No fix before you know the root cause. Applies to every failure, including simple ones and urgent ones.

## 1. Investigate

- Read the whole error, stack trace and warnings. Note files, lines and codes.
- Reproduce reliably with exact steps. If you cannot, gather more data and do not guess.
- Check what changed: git diff, recent commits, dependencies, config, environment.
- Multi-component systems (CI -> build -> deploy, API -> service -> DB): add logging at each boundary for what goes in and out, and check that env and config propagate. Run once, find the layer where it breaks, then dig into that layer only.
- Trace the bad value up the call chain to where it originates. Fix at the source, not where it shows up.

## 2. Compare

- Find similar working code. Read any reference implementation completely.
- List every difference between working and broken, however small. Check dependencies, config and assumptions.

## 3. Hypothesize

- State one hypothesis: "X is the cause because Y".
- Test it with the smallest possible change, one variable at a time. If wrong, form a new hypothesis and revert; do not stack fixes.
- If you do not understand something, say so and ask or research. Do not bluff.

## 4. Fix

- Write a failing reproduction first, using `test-driven-development`.
- Make one change for the root cause. No "while I'm here" edits or bundled refactors.
- Confirm with `verification-before-completion`: the repro passes, other tests pass, the issue is actually gone.
- After 3 failed fixes (especially if each exposes a new problem elsewhere), stop and discuss the architecture with the user before attempting a fourth.

## If no root cause exists

If it is truly environmental, timing-related or external, document what you checked, add handling (retry, timeout, clear error) and add logging.
