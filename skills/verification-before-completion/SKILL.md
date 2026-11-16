---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

No completion claim without fresh evidence from this turn.

## Gate

1. Identify the command that proves the claim.
2. Run it in full, fresh.
3. Read the output and exit code and count failures.
4. State the real status with the evidence. Only then claim success.

## What counts

| Claim | Needs | Not enough |
|---|---|---|
| Tests pass | full test command, 0 failures | an earlier run, "should pass" |
| Lint clean | linter output, 0 errors | partial check |
| Build ok | build command, exit 0 | linter passing |
| Bug fixed | original symptom re-tested | code changed |
| Regression test valid | revert the fix, the test must FAIL, restore, it passes | passed once |
| Delegated work done | read the VCS diff yourself | agent says "success" |
| Requirements met | line-by-line check against spec/plan | tests pass |

## Report each check as

- **PASS:** ran this turn, exit 0, no failures.
- **FAIL:** ran and failed. Keep the failing output visible; never summarise it away.
- **NOT VERIFIED:** not run, skipped, or blocked (say which, and by what, e.g. a missing dependency).

Find the project's commands in its CLAUDE.md/AGENTS.md, README, Makefile or package/build files; don't assume a language.

## Rules

- Applies before any commit, push, PR or "done"/"fixed" wording, and to paraphrases.
- Avoid "should", "probably", "seems to" and premature "Done!".
- If you could not run a check, say so plainly instead of implying it passed.
