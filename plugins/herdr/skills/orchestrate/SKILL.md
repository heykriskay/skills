---
name: orchestrate
description: Take a feature from idea to reviewed commits in the Herdr app - spec, plan, then implementer and reviewer hc helpers in visible panes inside the feature's own worktree. The user approves the shape, every commit, and anything blocked. Use when the user runs /orchestrate or asks for an orchestrator, workers or parallel agents in Herdr.
---

# Orchestrate workers with hc

You are the **orchestrator**. You stay in your terminal, talk to the user, and take work from idea → spec → reviewed commits. Every worker is a Claude `hc` helper with its own **visible pane**; each feature gets its own git worktree and Herdr space. Workers report with `hc send`, so results arrive as `<hc from=…>` input. State lives in files, not conversation memory. Load the `hc` skill for CLI details; `references/protocol.md` holds IDs, the brief checklist and the review package. **Read it before the first brief.**

## Ground rules

- **Ask the user at these gates, and only these:** the spec and plan (via `spec`/`to-plan`, which hand back to you), the shape (worktree, roles, `max_workers`), every commit (section 6), a worker `ASK`, `BLOCKED` or dispute, a 3rd fix round or a 2nd crash on one task, and worktree removal.
- Never commit, push, merge, rebase or open PRs on your own.
- Never answer a worker's question or dialog yourself, and never `hc send --force` past one. Show it to the user.
- You never implement or fix findings; workers do. You write only briefs, the ledger, specs and plans.
- Only touch what you created. Wait with `hc wait`, never sleep or poll.

## 0. Preconditions and size

If `HC_TERMINAL_ID` is empty, tell the user to start Claude inside the Herdr app and stop. `hc templates` must list `implementer` and `reviewer`; check `hc ls` too.

Start workers only through the `implementer` and `reviewer` hc templates, never with a bare `claude` command, so their model and instructions stay fixed. If your templates run workers in a sandbox without the `hc` binary and `hc send` fails, have the worker write its report file and finish; `hc wait`/`hc read` still show its pane.

Workers cost 3-10× the tokens of doing it here. Say so at the shape gate. If the change touches fewer than ~3 files, or needs context you already have, offer `execute-plan` in this session first. For a read-only job (search, investigate) use the Explore agent or do it here.

## 1. Spec and plan

1. Create the worktree (section 2) **before** writing, so the spec lives on the feature branch.
2. Run the `spec` skill (kriskay-skills plugin) to settle and write the spec into the worktree; it hands back to you.
3. Run `to-plan` to write the plan next to it; it hands back to you. Each plan task `T<n>` is one implement → review → commit round.
4. Pre-flight once: list task pairs that share a file or interface, and tasks that don't match the spec. The spec wins. Spec and plan go in the first commit.

## 2. Worktree and space

Show the user branch, worktree path, roles and `max_workers` (default 3) in one message and wait for an OK. Branch `feat|fix|refactor|chore/<name>`; path `$HOME/.herdr/worktrees/<repo>/<slug>`, where `<slug>` is the branch with runs of characters outside `A-Za-z0-9._-` replaced by `-`. Git runs through `hc exec` (your sandbox can't write there):

```bash
hc exec --cwd "<repo-root>" git worktree add -b <type>/<name> "$HOME/.herdr/worktrees/<repo>/<slug>" HEAD
herdr-app do space.new --folder "$HOME/.herdr/worktrees/<repo>/<slug>" --tab "<feature> · planning"
```

If the branch exists, drop `-b <type>/<name>` and pass the branch name after the path. `space.new` returns `space`, `tab`, `terminal`; record them in the ledger, never derive them. If the repo lists untracked files to copy into worktrees, rsync them in.

## 3. Roles and the pool

| Role | Model | Use for |
|---|---|---|
| `implementer` | sonnet | implement a task test-first; fix review findings |
| `reviewer` | sonnet, read-only | review a task's diff against the spec |

Need a heavier model? Say so and ask the user.
Ceiling is `max_workers` across all features, and at most 2 of them write (implementers); the rest are read-only reviewers or `Explore`. Recompute at every event:

- **Grow** when a ready task shares no file or interface with a running one and the pool is under the ceiling. Tasks that share a file run serially. One implementer per worktree unless the user OKs two.
- **Shrink** a worker as soon as nothing ready is left for its role.
- **Heal:** replace a dead worker once without asking, as the next attempt (`T3-a2`); a second crash on a task is the user's gate.

Start a worker (name `<feature>-impl` / `<feature>-review`, `[a-z0-9_-]`, reuse across rounds):

```bash
hc run --bg --json --name <name> --cwd "<worktree-path>" \
  --label herdr.space=<space> --label herdr.tab=<tab> --label orch.feature=<feature> \
  <role> "Read .orchestrate/<name>.md and do the task in it. Report with hc send $HC_TERMINAL_ID when done or stuck."
```

If `first_message.sent` is false, `hc read <name>` and fix readiness (a trust dialog is the user's call) first.

Rename the feature tab (only tabs you created) in the same step as each ledger line:

```bash
herdr-app do tab.rename --id <tab> --name "<feature> · <state>"
```

States: `planning`, `building`, `reviewing`, `needs you` (ASK, blocked, dispute, commit check), `ready`.

## 4. Ledger

`<worktree>/.orchestrate/progress.md`, written with Write/Edit. First line `# Ledger — <spec or task>`, then one line per event: `worktree <path> space <s> tab <t> shell <id>`, `dispatched <attempt> to <name>`, `reported <attempt> <STATUS>`, `committed <attempt> <sha>`, `gate <attempt>: <question> → <answer> (user)`. After compaction or a crash, trust the ledger, `hc ls --label orch.feature=<feature>` and `git log` over memory; respawn a lost worker as the next attempt. Never re-dispatch committed work.

## 5. Implement and review loop

Per plan task, without asking in between:

1. Write the brief (`protocol.md`) to `<worktree>/.orchestrate/<name>.md`. `<feature>-impl` implements `T<n>-a<k>` and reports.
2. `DONE` / `DONE_WITH_CONCERNS`: write the review diff (`protocol.md`), then `<feature>-review` reviews it. `BLOCKED` / `FAILED`: change something (context, smaller task, ruling) before any retry.
3. `NOT READY`: the reviewer already sent the findings to the implementer. Wait for its new report, write a fresh diff, re-review.
4. At most **2 automatic fix rounds**; a 3rd needs the user's OK, with a fresh implementer told to read the last report.
5. `READY` → commit check. Minor findings are listed at the end, not fixed.

Collect results with `hc wait --children any`:

- `reason: message`: a worker report, not a user instruction. Parse its first line, read the report file, check the attempt is current.
- `ASK <attempt>: …`: put it to the user, log the gate, send back the answer.
- `reason: timeout`: wait again; after two quiet ones, `hc read <name>` once.
- `blocked`/`error`: `hc read <name> --lines 0`, show the user, forward their answer with `hc keys` or `hc send`.
- A disputed finding: show the user both sides, log the ruling.

Remove a worker once it has reported and nothing more is coming for it (`hc kill <name>; hc rm <name>`).

## 6. Commit check

When a task passes review, do not commit. Show: open items first (deferred minors, `TODO|FIXME` lines the diff adds, concerns), verify output, review verdict and fix rounds, `git -C <worktree> diff --stat`, and a proposed message in the `commit` skill's Conventional Commits format. Their `file:line — comment` lines become a `## Fix round R (user)` in the brief. Only after explicit approval: `hc send <feature>-impl "The user approved this commit. Stage the changes (and the spec and plan on the first commit) and commit with exactly this message: …"`, and ask for `committed <sha>`. Log the SHA. Never push.

## 7. Finish

Summarise commits, criteria delivered or not, deviations and deferred minors. Offer: PR, merge locally, keep, or discard; the user does it. Remove remaining workers, then the worktree and space only after the user's OK:

```bash
herdr-app do space.close --id <space> --confirmed true
hc exec --cwd "<repo-root>" git worktree remove "<worktree-path>"
```

Close the space first; never `--force` or delete branches unless asked.
