# 0002: Test first, and prove it before saying "done"

- **Status:** Accepted
- **Date:** 2026-11-16

## Context

Language models are good at writing code that looks right, and at saying it works without checking.
A claim of "tests pass" is worth nothing unless the tests ran.

## Decision

`test-driven-development` requires a failing test before production code. `verification-before-completion`
forbids "done" or "tests pass" unless the check ran in the same turn, with the output shown.
`systematic-debugging` requires a root cause before a fix.

## Consequences

- Every change comes with a test that shows the behaviour.
- Claims in a session can be trusted, because each one carries its evidence.
- Small throwaway tasks take a little longer. For pure exploration you can ask Claude to skip it.
