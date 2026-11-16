# Claude Code skills

A skill set for [Claude Code](https://code.claude.com): a small, opinionated workflow
that takes a feature from **idea → spec → plan → tested commits → PR**, with you approving each step.

Most skills are trimmed and adapted from great open-source sets (see [Credits](#credits));
`commit` and `orchestrate` are original to this repo.

## The workflow in one picture

```
grilling  →  to-spec  →  (you OK)  →  to-plan  →  (you OK)  →  execute-plan  →  pr
  ask         write the               break it into            build it task by     write the
  questions   design doc              small test-first tasks   task, commit each    PR text
```

Every file for one feature shares a date and a name in `specs/`:
`specs/2026-11-16-login-design.md`, `…-plan.md`, `…-context.md`.

While building, three "discipline" skills kick in on their own:
`test-driven-development`, `systematic-debugging` and `verification-before-completion`.

## The skills, simply explained

### Planning

| Skill | In plain words |
|---|---|
| **grilling** | Claude interviews you about your idea until nothing is left unclear. Asks a few multiple-choice questions at a time, with its recommended answer first. Looks up facts itself. |
| **to-spec** | Turns that conversation into a design doc (problem, solution, user stories, acceptance criteria). No more questions; it waits for your OK before any code. Small features (≤3 files) get the task list in the same doc. |
| **to-plan** | Turns the approved spec into a checklist of small tasks: which files, which function names, which test to write first, which command proves it works. |

### Building

| Skill | In plain words |
|---|---|
| **execute-plan** | Works through the plan task by task without asking "shall I continue?". Writes the test first, makes it pass, ticks the box, proposes a commit. Small decisions it makes on its own get written down as "rulings" so you can check them after. Ends with a review against the spec. |
| **test-driven-development** | Red → green → refactor. No production code without a failing test first. |
| **systematic-debugging** | Find the root cause before fixing anything. Reproduce, compare with working code, test one hypothesis at a time. After 3 failed fixes, stop and talk. |
| **verification-before-completion** | Claude may not say "done" or "tests pass" without running the command *this turn* and showing the result. Each check is PASS, FAIL or NOT VERIFIED. |

### Reviewing and shipping

| Skill | In plain words |
|---|---|
| **review-since** | Reviews everything changed since a commit or branch on two axes: *does it follow the repo's coding standards?* and *does it do what the spec says?* |
| **commit** | Proposes a short [Conventional Commits](https://www.conventionalcommits.org) message and only commits after you say yes. Refuses to stage secrets. |
| **pr** | Writes a PR description: a small sketch of the change, before/after evidence, and how risky the merge is (one-way or two-way door, blast radius). |
| **handoff** | Type `/handoff` at the end of a session. Saves a short "where we are" file so a fresh session can pick up the work. |

### Multi-agent (optional, needs [Herdr](https://github.com/herdrdev/herdr-core))

| Skill | In plain words |
|---|---|
| **hc** | Manual for `hc`, the Herdr terminal tool: start helper agents or slow commands in their own terminal, wait for them, read their reports. |
| **orchestrate** | Claude becomes a team lead: it writes the spec, then hands each task to an *implementer* agent and a *reviewer* agent in separate panes and a separate git worktree. You still approve every commit. Costs 3-10× more tokens, so only for bigger features. |

Ignore these two if you don't use Herdr; the rest of the workflow works without them.

## What else is in here

| Folder | What it is |
|---|---|
| `agents/` | Sub-agent roles: **Explore** (fast read-only search on Haiku), **implementer** (writes code test-first), **reviewer** (read-only, checks a diff against the spec). |
| `rules/` | Language rules that load only for matching files: `java.md` (JUnit 5, Arrange/Act/Assert), `shell.md` (strict Bash, quoting, shellcheck). |
| `hooks/` | `lint.sh` runs shellcheck/yamllint after every edit and feeds problems back to Claude. `log-commands.sh` logs every Bash command Claude runs to `~/.claude/bash-commands.jsonl`; `trim-command-log.sh` keeps 30 days of it. |
| `statusline.sh` | A three-line status bar: model, folder, git branch, PR, context %, usage limits, cost. |
| `examples/` | A sample `settings.json` (safe permissions, sandbox, hooks wired up), `mcp.json` and `CLAUDE.md`. Read and adapt; don't copy blindly. |

## Install

Copy what you want into `~/.claude/` (or a project's `.claude/`):

```bash
git clone https://github.com/heykriskay/claude-skills.git
cd claude-skills
./install.sh            # copies skills, agents, rules, hooks, statusline into ~/.claude
```

`install.sh` never overwrites `settings.json` or `CLAUDE.md`; merge the ones in `examples/` by hand.
To install a single skill: `cp -r skills/commit ~/.claude/skills/`.

**Needs:** `jq` for the hooks and status line; `shellcheck` and `yamllint` are optional (skipped if missing).

## How skills trigger

Claude loads a skill on its own when your request matches the skill's `description`.
`handoff` is the exception: it only runs when you type `/handoff`. You can always force any skill with `/<name>`.

## Credits

- [mattpocock/skills](https://github.com/mattpocock/skills) (MIT): `grilling`, `to-spec`, `review-since` (was `code-review`), `handoff`
- [obra/superpowers](https://github.com/obra/superpowers) (MIT): `test-driven-development`, `systematic-debugging`, `verification-before-completion`; `to-plan` and `execute-plan` are cut down from `writing-plans` and `executing-plans`
- [humanlayer/skills](https://github.com/humanlayer/skills) (MIT): `pr` is based on `show-me` by Dex Horthy
- [herdrdev/herdr-core](https://github.com/herdrdev/herdr-core) (Apache-2.0): `hc` is trimmed from `hc --skill`

Full notices in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

[MIT](LICENSE)
