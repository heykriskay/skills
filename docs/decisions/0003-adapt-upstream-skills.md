# 0003: Adapt and trim proven skills instead of writing all from scratch

- **Status:** Accepted
- **Date:** 2026-11-16

## Context

Good open-source skills already exist for spec writing, TDD and debugging. Used as they are, they are
long, overlap with each other and don't hand work on to each other.

## Decision

Start from proven skills (MIT and Apache-2.0 licensed), cut them down to what changes Claude's
behaviour, and wire them into one chain where each skill names the next. Credit every source in
[THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md). Write new skills only where nothing fits
(`commit`, `orchestrate`).

## Consequences

- Less to maintain, and the ideas behind each skill are already tested by many users.
- Shorter skills cost fewer tokens every session.
- Improvements upstream don't arrive by themselves; pulling them in is manual.
