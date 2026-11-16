---
name: execute-plan
description: "Run an approved `specs/*-plan.md` task by task in this session: TDD on every task, a commit per task through `commit`, then a `review-since` review against the spec. Use right after the user approves a plan from `to-plan`, or when they ask to execute, implement or resume a plan."
---

Execute the plan yourself, task by task. Prove every step with a test you watched fail and then pass, and leave a record on disk that survives compaction.

**Keep going.** Between tasks, don't ask "should I continue?". Only these stop you:

1. A task's commit: propose it through `commit` and wait for the OK.
2. Something irreversible or destructive.
3. Something security-sensitive.
4. Anything outside this repo that norms say you ask about first: push, merge, publish, CI/CD config.
5. A plan so broken that every path forward is a guess.

Everything else is a **ruling**: decide it, record it, keep going.

## Setup

1. Read the plan once, then the spec it names. The spec is the authority: conflicts in the plan resolve against it. No spec → note it under `## Rulings`; every ruling is provisional.
2. Record the starting commit (`git rev-parse HEAD`) as `**Base:** <sha>` under the plan's header. It's the fixed point for the final review.
3. **Resume:** ticked checkboxes in the plan are done. Start at the first unticked task. After compaction, trust the plan file and `git log` over your memory.
4. Load `test-driven-development` now, before Task 1. It governs every step below.
5. Make one todo per task.

## Each task

1. Work the steps in order. Run every command, read its output, compare it with what the step expects:
   - **Matches:** tick the checkbox in the plan file, next step.
   - **The code is wrong:** use `systematic-debugging`. Find the cause; never patch the output to match.
   - **The plan is wrong** (contradicts the spec, an interface doesn't match an earlier task's **Produces**, a command can't work): make the smallest change that satisfies the spec and add `- Task <N>: <finding> → <decision> (cost if wrong: <…>)` under `## Rulings` at the end of the plan.
2. Before calling the task done, `verification-before-completion`: every named test ran in this task, the last full run passed, and every deviation has a ruling.
3. Commit through `commit`, proposing the plan's commit message. Include the ticked plan file. After the OK, take the next task straight away. If the user declines the commit, untick that task's boxes in the plan and ask what to change.

## Final review

After the last task, run `review-since` here with the **Base** commit and the spec. Then grade each finding by what someone using the software gets if it ships, not by the label the reviewer gave it:

- **Critical / Important:** fix in one pass, each with a test that reproduces it: watch it fail, fix, watch it pass, run the whole suite. Commit through `commit`.
- **Minor:** don't fix. List under "Deferred minors".
- **Not fixing a finding** is a ruling: record why the code stands.

## Finish

End with one message:

- **Acceptance criteria:** the spec's checklist, each with the command or test that proves it.
- **Rulings I made:** every line under `## Rulings`, in order.
- **Deferred minors.**
- **Next step:** on a feature branch, offer `pr`. Otherwise say it's done. If the session ends with work left, suggest `/handoff`.
