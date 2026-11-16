---
name: to-spec
description: "Turn the current conversation into a spec at `specs/YYYY-MM-DD-<slug>-design.md`: no interview, just synthesis of what you've already discussed. Use right after `grilling` ends with a shared understanding, or when the user asks for a spec."
---

Take the current conversation and codebase understanding and produce a spec. Do NOT interview the user; synthesize what you already know.

## Process

1. Explore the repo if you haven't already. Use the project's own terms throughout.
2. Sketch the seams at which you'll test the feature. Prefer existing seams, at the highest point possible; the ideal number of new seams is one.
3. Write the spec with the template below to `specs/YYYY-MM-DD-<slug>-design.md` at the repo root (today's date; create `specs/` if needed). The date and slug name every file for this feature: `to-plan` writes `-plan.md` next to it and `handoff` writes `-context.md`.
4. Show the path and the seams, and ask the user to approve both. **Nothing gets built before that OK:** no product code, scaffolding, dependency installs or build-file edits. Requested changes → edit the spec and ask again.
5. On approval: if `orchestrate` called this skill, return to it. Otherwise, if the feature touches 3 or fewer files, write the `to-plan` task list into the same `-design.md` (following `to-plan`'s template and rules), ask for one OK on it, and go straight to `execute-plan`, skipping `to-plan`. Otherwise invoke `to-plan` and no other skill. The spec is committed with the feature, through `commit`.

## Template

```markdown
## Problem Statement

The problem, from the user's perspective.

## Solution

The solution, from the user's perspective.

## User Stories

Numbered, only as many as there are distinct behaviours:

1. As an <actor>, I want a <feature>, so that <benefit>

## Implementation Decisions

- Modules built or modified, and their interfaces
- Technical clarifications from the developer
- Architectural decisions, schema changes, API contracts, specific interactions

No file paths or code snippets: they go stale quickly.

## Testing Decisions

- What makes a good test (external behaviour, not implementation details)
- Which modules are tested
- Prior art: similar tests in the codebase

## Acceptance Criteria

Observable outcomes that prove the feature is done, each checkable by running something. The implementer and reviewer work against these.

- [ ] Criterion 1
- [ ] Criterion 2

## Out of Scope

What this spec does not cover.
```
