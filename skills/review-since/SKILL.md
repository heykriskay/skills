---
name: review-since
description: "Review the changes since a fixed point (commit, branch, tag or merge-base) on two axes: Standards, against the repo's documented coding standards, and Spec, against the originating issue or spec. Use when the user wants a branch, PR or work in progress reviewed, or says \"review since X\"."
---

Two-axis review of the diff between `HEAD` and a fixed point:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the originating issue / spec?

Review both axes yourself in this session. Only if the diff exceeds about 800 lines, spawn one fresh-context sub-agent per axis in the foreground and aggregate their reports.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (SHA, branch, tag, `main`, `HEAD~5`). If they didn't specify one, ask.

Confirm it resolves (`git rev-parse <fixed-point>`). The diff is `git diff <fixed-point>...HEAD` (three-dot, against the merge-base); the commits are `git log <fixed-point>..HEAD --oneline`. An empty diff stops here.

### 2. Identify the spec source

In order: a path the user passed; a `specs/*-design.md` matching the branch or feature (and its `-plan.md` sibling), else a spec under `docs/`; otherwise ask. If there is none, skip the Spec axis and say so.

### 3. Identify the standards sources

Find every file that documents how code is written; `CODING_STANDARDS.md` and `CONTRIBUTING.md` must be on the list if they exist. On top of that, always check this **smell baseline** from Fowler's _Refactoring_: Mysterious Name, Duplicated Code, Feature Envy, Repeated Switches, Shotgun Surgery, Speculative Generality.

Rules: a documented repo standard always wins over the baseline. Smells are judgement calls ("possible Feature Envy"), never hard violations. Skip anything tooling already enforces.

### 4. Review

**Standards:** per file/hunk, (a) every place the diff violates a documented standard, citing the file and rule; (b) any baseline smell, naming it and quoting the hunk.

**Spec:** (a) requirements missing or partial; (b) behaviour that wasn't asked for (scope creep); (c) requirements that look implemented but wrong. Quote the spec line for each.

### 5. Aggregate

Present the results under `## Standards` and `## Spec`. Don't merge or rerank across axes. End with one line: findings per axis and the worst issue within each.
