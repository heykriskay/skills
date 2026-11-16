---
name: to-plan
description: "Turn an approved spec into a task-by-task implementation plan at `specs/YYYY-MM-DD-<slug>-plan.md`: files, interfaces, test-first checkbox steps, a verify command per task. Use right after the user approves a spec from `to-spec`, or when they ask for a plan."
---

Write a plan for an engineer who knows the language but not this codebase or this spec. They can write the bodies; what they can't know is what was decided: which files, which names and signatures, which values from the spec, which tests prove each task. The plan records those decisions and nothing else.

## Process

1. Find the spec: the `specs/*-design.md` named in the arguments, or the newest one matching this conversation. No spec → stop and suggest `to-spec` first.
2. Read the code it touches. Use the project's own names.
3. Map the files: which ones are created or modified, and what each is responsible for. Follow the patterns already in the repo.
4. Cut tasks. A task is the smallest unit with its own test cycle that a reviewer could reject on its own. Fold setup, config and docs into the task that needs them.
5. Write the plan with the template below to `specs/YYYY-MM-DD-<slug>-plan.md`, reusing the spec's date and slug.
6. Self-review (below), fix inline, then hand off.

## Template

````markdown
# <Feature> Plan

**Spec:** `specs/YYYY-MM-DD-<slug>-design.md`
**Goal:** <one sentence>
**Approach:** <2-3 sentences>

## Constraints

<Project-wide requirements from the spec, one line each, exact values copied verbatim.>

---

### Task 1: <component>

**Files:** create `path/a`, modify `path/b`, test `path/test_b`
**Produces:** <names, signatures and types later tasks rely on>

- [ ] Write failing test `test_name`: <assertions with the spec's exact values>
- [ ] Run `<command>`, expect FAIL: <reason>
- [ ] Implement `name(params) -> type` in `path/a`
- [ ] Run `<command>`, expect PASS
- [ ] Commit: `<type>(<scope>): <summary>`
````

## What a step holds

A step is done when it leaves exactly one reasonable thing to write.

- **Test step:** test name and assertions, with the spec's values in them.
- **Code step:** signature and file. A body only for an algorithm the signature and test don't determine.
- **Verify step:** the command and the output that means it passed.
- **Cross-task reference:** point at that task's **Produces** line; don't repeat its code.

No placeholders: "TBD", "handle edge cases", "add validation", "write tests" decide nothing. A plan longer than the code it describes has written the code instead.

## Self-review

1. **Coverage:** every acceptance criterion in the spec maps to a task. Add a task for any gap.
2. **Names:** signatures and names match across tasks (`clearLayers` in task 3 is not `clearAllLayers` in task 7).
3. **Edge cases:** the inputs the spec implies but no test exercises, most likely first. Add a test step for each to the task that owns the code.

## Hand off

Show the plan path and ask the user to approve it. Requested changes → edit the plan and ask again. Nothing gets built before that OK.

On approval: if `orchestrate` called this skill, return to it and don't offer `execute-plan`. Otherwise invoke `execute-plan` and no other skill, with no further question.

The spec and plan are committed with the feature, through the `commit` skill.
