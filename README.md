# Claude Code skills

[![Validate](https://github.com/heykriskay/skills/actions/workflows/validate.yml/badge.svg)](https://github.com/heykriskay/skills/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

This is my personal Claude Code setup. It is deliberately small: Claude Code's built-ins already plan,
review and verify, so this repo only adds what they don't know, my taste and my checks, and enforces
the checks with hooks instead of long instructions. The reasoning, with sources, is in
[docs/research](docs/research/modern-claude-code-setup-2026.md).

Feel free to use it, copy it or change it to fit your own workflow.

## Install

**As a plugin** (easiest, gets updates). In Claude Code:

```
/plugin marketplace add heykriskay/skills
/plugin install kriskay-skills@heykriskay
```

Skills are then called with a prefix, like `/kriskay-skills:spec`. The plugin includes the skills, the
search agent and both hooks.

**Or copy the files**, if you also want the rules, status line and command log, or prefer plain names like `/spec`:

```bash
git clone https://github.com/heykriskay/skills.git
cd skills && ./install.sh          # add --herdr for the Herdr add-on
```

This copies everything into `~/.claude/`. Then merge [examples/settings.json](examples/settings.json) and
[examples/CLAUDE.md](examples/CLAUDE.md) into your own. Hooks and the status line need `jq`. Use one way, not both.

## The flow

```
/spec (only if the idea is fuzzy) → plan mode → build → /code-review → pr
```

Most of it is Claude Code itself:

| Step | Use |
|---|---|
| Pin down a fuzzy idea | `/spec` (this repo) |
| Plan | plan mode (shift+tab, or `/plan <task>`) |
| Keep going until done | `/goal all acceptance criteria in specs/<file> hold` |
| Check | the `verify` hook (this repo), `/verify` |
| Review | `/code-review` (`--fix` to apply), `/simplify`, `/security-review` |
| Parallel work | background subagents, `/batch` |
| Continue later | `/rename`, then `/resume`; `/compact` before a break, `/rewind` to undo turns |
| PR description | `pr` (this repo) |

## What's in here

| Part | What it does |
|---|---|
| `spec` skill | Interviews you until every decision is made, then writes `specs/YYYY-MM-DD-<slug>.md`. |
| `pr` skill | PR body with a summary sketch, before/after evidence and merge danger. |
| `Explore` agent | Read-only search on haiku. The built-in Explore runs on your main model. |
| `lint.sh` hook | After each edit, runs shellcheck or yamllint on the file and sends problems back. |
| `verify.sh` hook | When Claude stops after changing code, runs your check command and sends failures back. |
| `rules/` | Java and shell rules that load only for matching files (copy install). |
| `statusline.sh` | Model, branch, PR, context %, plan limits, cost (copy install). |
| `log-commands.sh` | Logs every Bash command Claude runs to `~/.claude/bash-commands.jsonl` (copy install). |

**Turn on verify** in a project by putting its check command on the first line of `.claude/verify`:

```bash
echo 'npm test --silent' > .claude/verify
```

Or set `CLAUDE_VERIFY_CMD`. Without either, the hook does nothing. It only runs when the working tree
changed since the last pass, and skips when Claude is already fixing a failure it reported.

**Herdr users:** the `hc` and `orchestrate` skills now live in the optional
[kriskay-herdr](plugins/herdr/README.md) plugin.

## Keep it lean

Run `/doctor prompt-audit` now and then: it flags lines in CLAUDE.md, rules, skills and agents that
current models no longer need. `/context` shows what each session loads.

## Why it works this way

The main choices are recorded in [docs/decisions](docs/decisions/). [0006](docs/decisions/0006-lean-on-built-ins.md)
explains the move from 13 process skills to this.

## Contributing

Ideas and fixes are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md); run `./scripts/validate.sh` before opening a PR.

## Credits

Adapted from [mattpocock/skills](https://github.com/mattpocock/skills), [humanlayer/skills](https://github.com/humanlayer/skills)
and [herdr-core](https://github.com/herdrdev/herdr-core); versions before 2.0 also drew on
[obra/superpowers](https://github.com/obra/superpowers). See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

[MIT](LICENSE)
