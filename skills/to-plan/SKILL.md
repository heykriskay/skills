---
name: to-plan
description: "Turn an approved spec into a task-by-task plan at `specs/YYYY-MM-DD-<slug>-plan.md`: files, interfaces, test-first steps and a verify command per task. Use right after the user approves a spec from `spec`, or when they ask for a plan."
---

Write a plan for an engineer who knows the language but not this codebase or the spec. Record what was decided, which files, names, signatures and values from the spec, and which tests prove each task. They can write the bodies.

## Process

1. Find the spec: the `specs/*.md` named in the arguments, or the newest one from this conversation. No spec: suggest `spec` first.
2. Read the code it touches and use the project's own names and patterns.
3. Cut tasks. A task is the smallest unit with its own test cycle that a reviewer could reject on its own. Fold setup, config and docs into the task that needs them.
4. Write the plan next to the spec, reusing its date and slug, even for a small feature.
5. Check it: every acceptance criterion maps to a task, names match across tasks, and the edge cases the spec implies each have a test step.

## Template

````markdown
# <Feature> plan

**Spec:** `specs/YYYY-MM-DD-<slug>.md`
**Goal:** <one sentence>

## Constraints

<project-wide requirements from the spec, exact values copied>

### Task 1: <component>

**Files:** create `path/a`, modify `path/b`, test `path/test_b`
**Produces:** <names and signatures later tasks rely on>

- [ ] Failing test `test_name`: <assertions with the spec's values>
- [ ] Run `<command>`, expect FAIL: <reason>
- [ ] Implement `name(params) -> type` in `path/a`
- [ ] Run `<command>`, expect PASS
- [ ] Commit: `<type>(<scope>): <summary>`
````

A step is done when it leaves one reasonable thing to write. "Handle edge cases" or "add validation" decide nothing; a plan longer than the code it describes has written the code instead.

## Hand off

Show the plan path and ask for approval. After the OK, run `execute-plan` (or return to `orchestrate` if it called you).
