---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea before any code is written. Use when the user hands over a user story, feature request, or assignment, wants to stress-test their thinking, or uses any 'grill' trigger phrases. Skip for small fixes with nothing left to decide.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled. Ask the whole frontier in one round, then wait for the answers before the next. A question that depends on another still open in this round belongs to a later round. Each round reshapes the tree: recompute the frontier and repeat.

Ask every round with the `AskUserQuestion` tool, never as plain-text chat questions: one question per frontier decision (max 4 per call; use several calls if the frontier is bigger), 2-4 mutually exclusive options with your recommendation first and `(Recommended)` at the end of its label, trade-offs in each option's `description`. No "Other" option; the tool adds it.

Finding _facts_ is your job, never the user's. Look them up yourself, or dispatch a sub-agent for them, and don't block on it: only the questions downstream of the fact wait. The _decisions_ are the user's.

The session is done when the frontier is empty: every branch visited, nothing silently assumed. Don't act until the user confirms you share an understanding.

## Next

Once the user confirms, invoke `to-spec` and no other skill. Two exceptions:

- A calling skill (e.g. `orchestrate`) already says what comes next: follow it.
- The user only wanted to stress-test an idea, not build it: stop.
