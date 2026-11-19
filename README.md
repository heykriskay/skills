# Claude Code skills

[![Validate](https://github.com/heykriskay/skills/actions/workflows/validate.yml/badge.svg)](https://github.com/heykriskay/skills/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

This is my personal Claude Code setup, built on one idea from Lydia Hallie's talk
["Rethinking Claude Code Best Practices"](https://www.youtube.com/watch?v=vlfCjWuv4es) (Anthropic, Nov 2026):
every step I take out of the loop needs a replacement.

| I used to... | Now | In this repo |
|---|---|---|
| Steer | The model, with instructions only for what it can't infer | Short skills for my spec → plan → TDD → commit → PR process |
| Approve | Auto mode | `autoMode.environment`: which repos, registries and clusters I trust |
| Say no | Deny rules and the sandbox | Deny rules only for what can't be undone; a sandbox that keeps commands away from secrets |
| Check | Hooks and CI | Lint on every edit, touched tests when a task completes, the full suite when Claude stops |

Feel free to use it, copy it or change it to fit your own workflow. Research and sources:
[docs/research](docs/research/modern-claude-code-setup-2026.md).

## Install

**As a plugin** (skills, search agent and hooks). In Claude Code:

```
/plugin marketplace add heykriskay/skills
/plugin install kriskay-skills@heykriskay
```

Skills are then called with a prefix, like `/kriskay-skills:spec`.

**Or copy the files**, to also get the rules, status line and command log, with plain names like `/spec`:

```bash
git clone https://github.com/heykriskay/skills.git
cd skills && ./install.sh          # add --herdr for the Herdr add-on
```

Then merge [examples/settings.json](examples/settings.json) into `~/.claude/settings.json` and
[examples/AGENTS.example.md](examples/AGENTS.example.md) into `~/.claude/CLAUDE.md`. Hooks need `jq`;
the sandbox on Linux needs `bubblewrap` and `socat`. Use one way, not both.

**Per project**, copy this repo's [.claude/settings.json](.claude/settings.json) and adjust its
`allowedDomains`. Committed deny rules and sandbox settings travel with every checkout, including cloud
sessions where your `~/.claude` doesn't exist.

## The flow

```
spec → to-plan → execute-plan (test first, a commit per task) → pr
```

| Skill | What it does |
|---|---|
| `spec` | Asks you about every open decision, then writes `specs/YYYY-MM-DD-<slug>.md`. |
| `to-plan` | Splits the spec into small, test-first tasks. |
| `execute-plan` | Builds the plan task by task, one commit each, then runs `/code-review`. |
| `test-driven-development` | A failing test before the code, plus how to write tests that catch real breaks. |
| `commit` | Proposes a Conventional Commits message, commits after your OK. |
| `pr` | PR body with a summary sketch, before/after evidence and merge danger. |

| `delegate` | Picks where a task goes: a cheap search agent, `/batch`, a cloud session, or Codex for a second opinion. |

Built-ins cover the rest: `/code-review`, `/simplify`, `/security-review`, `/goal`, `/rename` + `/resume`.

## Claude, Codex and OpenCode together

One source, read by all three. Claude stays the main agent; the others are a second opinion or a
second pair of hands, and their output is advice that Claude checks.

| Shared piece | Claude Code | Codex | OpenCode |
|---|---|---|---|
| Instructions | `.claude/CLAUDE.md` imports `@../AGENTS.md` | `AGENTS.md` | `AGENTS.md` |
| Your global file | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` | `~/.config/opencode/AGENTS.md` |
| Skills | `~/.claude/skills` | `~/.agents/skills` (`install.sh --codex` links them) | reads `~/.claude/skills` |
| Safety | `examples/settings.json` | [examples/codex/config.toml](examples/codex/config.toml): workspace-write sandbox, no network | [examples/opencode/opencode.json](examples/opencode/opencode.json): the same deny rules |
| Checks | hooks | the same scripts via [examples/codex/hooks.json](examples/codex/hooks.json) | no command hooks; rely on CI |

Link your global instructions once: `ln -s ~/.claude/CLAUDE.md ~/.codex/AGENTS.md` and
`ln -s ~/.claude/CLAUDE.md ~/.config/opencode/AGENTS.md`. Codex asks you to trust new hooks the first time.

**Picking the agent.** The `delegate` skill decides when work leaves the session, from its description:
search goes to the haiku `Explore` agent, repeated edits to `/batch`, long or ambiguous work to a cloud
session (`claude --cloud`), and a second opinion to Codex through OpenAI's
[Codex plugin for Claude Code](https://github.com/openai/codex-plugin-cc) (`/codex:adversarial-review`,
`/codex:rescue`, `/codex:review`), which `examples/settings.json` enables. Run `/codex:setup` once.
Everything else stays in the session: extra agents cost far more tokens than they usually save.

## Checks

| Hook | When | Runs |
|---|---|---|
| `lint.sh` | After each edit | shellcheck, yamllint, gofmt + go vet, ruff, the project's eslint |
| `verify.sh touched` | A task is marked complete | Tests for the changed files: Go packages, matching pytest files, `vitest related` / `jest --findRelatedTests`, `-Dtest=<Class>Test` |
| `verify.sh full` | Claude stops | The whole suite: `go test`, Maven/Gradle, `pytest`, the package's `test` script, or `.claude/verify` |
| `guard-kube.sh` | Before a shell command | Blocks `kubectl`/`oc` delete or apply on a context that isn't a local cluster |

Failures exit 2, which sends Claude back to fix them (exit 1 wouldn't). A missing linter or test setup is
skipped. Override the suite with a `.claude/verify` file or `CLAUDE_VERIFY_CMD`.
`./scripts/test-hooks.sh` tests the hooks themselves and runs in CI.

The sandbox only covers shell commands and what they start. Claude's own file tools, MCP servers and hooks
run outside it, so the deny rules still matter. For long unattended work, use a cloud session, where your
secrets aren't on the machine at all.

## Also in here

| Part | What it does |
|---|---|
| `Explore` agent | Read-only search on haiku; the built-in Explore runs on your main model. |
| `rules/` | Java and shell rules that load only for matching files (copy install). |
| `statusline.sh` | Model, branch, PR, context %, plan limits, cost (copy install). |
| `log-commands.sh` | Logs every Bash command Claude runs to `~/.claude/bash-commands.jsonl` (copy install). |
| [kriskay-herdr](plugins/herdr/README.md) | Optional: implementer and reviewer agents in Herdr panes. |

`examples/settings.json` also turns on experimental [Code Mode](https://code.claude.com/docs/en/code-mode.md).

Run `/doctor prompt-audit` after a model upgrade: it flags lines current models no longer need.

## Why it works this way

The main choices are recorded in [docs/decisions](docs/decisions/), most recently
[0006](docs/decisions/0006-lean-on-built-ins.md).

## Contributing

Ideas and fixes are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md); run `./scripts/validate.sh` before opening a PR.

## Credits

Adapted from [mattpocock/skills](https://github.com/mattpocock/skills), [obra/superpowers](https://github.com/obra/superpowers),
[humanlayer/skills](https://github.com/humanlayer/skills) and [herdr-core](https://github.com/herdrdev/herdr-core).
See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

[MIT](LICENSE)
