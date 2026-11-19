---
name: spec
description: "Settle a feature with the user and write it down as a short spec at `specs/YYYY-MM-DD-<slug>.md`. Use when the user hands over a user story, assignment or feature request, asks to be grilled, or says /spec. Skip it for small fixes with nothing left to decide."
argument-hint: "The feature or idea to pin down"
---

Turn a fuzzy idea into decisions the user has made, before any code.

## Interview

Map the open decisions as a tree: some only make sense once others are settled. Each round, ask every decision whose prerequisites are settled, with `AskUserQuestion` (2-4 options each, your recommendation first). Recompute and repeat until nothing is open.

Facts are your job: look them up in the code or docs instead of asking. Decisions are the user's. If the user only wanted to stress-test an idea, stop here.

## Write

Save `specs/YYYY-MM-DD-<slug>.md` at the repo root, in the project's own terms:

```markdown
# <Feature>

## Problem
## Decisions
<what was decided, and the reason when it isn't obvious>
## Acceptance criteria
- [ ] <observable outcome, checkable by running something>
## Out of scope
```

No file paths or code: they go stale. Show the path and ask for an OK.

## Next

After the OK, run `to-plan`. If `orchestrate` called you, return to it instead.
