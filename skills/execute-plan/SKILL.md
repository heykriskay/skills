---
name: execute-plan
description: "Build an approved `specs/*-plan.md` task by task in this session: test first, a commit per task through `commit`, then a fresh-context review. Use right after the user approves a plan from `to-plan`, or to resume one."
---

Build the plan yourself, task by task, and leave a record on disk that survives compaction.

You stop for: each task's commit (through `commit`), anything irreversible or security-sensitive, pushing or CI/CD changes, and a plan so broken that every way forward is a guess. Everything else is a ruling: decide it, write it down, carry on.

## Setup

1. Read the plan, then the spec it names. The spec wins where they disagree.
2. Record `git rev-parse HEAD` as `**Base:** <sha>` under the plan's header.
3. Resuming: ticked boxes are done; start at the first unticked task. Trust the plan file and `git log` over memory.
4. Create one task (TaskCreate) per plan task, so the TaskCompleted hook runs the tests for what each one touched.

## Each task

1. Work the steps with `test-driven-development`, running each command and comparing its output with what the step expects. Tick each box as it matches.
2. When the code is wrong, find the root cause before fixing. When the plan is wrong, make the smallest change that satisfies the spec and add `- Task <N>: <finding> → <decision>` under `## Rulings` at the end of the plan.
3. Mark the task completed, then propose the plan's commit message through `commit`, with the ticked plan file included. If the user declines, untick the task and ask what to change.

## Finish

Run `/code-review` against the **Base** commit. Fix Critical and Important findings with a reproducing test each and commit them; list Minor ones as deferred. Then report, in one message:

- each acceptance criterion with the command or test that proves it, and its actual output
- the rulings you made
- deferred minors
- next step: offer `pr` on a feature branch. If work is left, `/rename` the session so it can be `/resume`d.
