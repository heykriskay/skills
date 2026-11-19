# Changelog

All notable changes to this project. Versions follow [Semantic Versioning](https://semver.org);
the plugin version lives in `.claude-plugin/plugin.json`.

## Unreleased

## 2.0.0 - 2026-11-19

Rebuilt around Lydia Hallie's "Rethinking Claude Code Best Practices" (Anthropic, Nov 2026): every step
taken out of the loop gets a replacement. The model steers, auto mode approves, deny rules and the sandbox
say no, hooks and CI check. See [docs/decisions/0006](docs/decisions/0006-lean-on-built-ins.md).

- **Steering:** the spec → plan → TDD → commit → PR chain stays, slimmed to what current models need
  (`spec` merges `grilling` and `to-spec`; `/doctor prompt-audit` fixes applied). **Breaking:** removed
  `systematic-debugging`, `verification-before-completion`, `review-since` and `handoff`; hooks,
  `/code-review`, `/rename` and `/resume` replace them.
- **Approving:** `examples/settings.json` adds `autoMode.environment` entries (with `"$defaults"`) for
  trusted source control, registries and which clusters count as remote. `git push` moves from deny to ask.
- **Saying no:** deny rules only for what can't be undone (secret reads, discarding uncommitted work,
  force-push, `rm -rf` outside the repo); `guard-kube.sh` blocks `kubectl`/`oc` delete or apply on
  non-local contexts. The repo commits its own rules and sandbox in `.claude/settings.json`.
  `git commit` and `git push` run outside the sandbox (`excludedCommands`): commit signing talks to a
  local service, and push needs the GitHub token the sandbox strips from every other command.
- **Checking:** `lint.sh` covers shell, YAML, Go, Python and JS/TS; `verify.sh` runs the touched tests on
  `TaskCompleted` and the full suite on `Stop` (Go, Maven/Gradle, pytest, npm/pnpm/yarn), exiting 2 until
  they pass. `scripts/test-hooks.sh` tests the hooks in CI.
- `examples/settings.json` also turns on experimental Code Mode, which needs feature-flag fetching, so
  `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` becomes `DISABLE_ERROR_REPORTING`; and task tools on every
  model (`CLAUDE_CODE_ENABLE_TODO_TOOLS`) so `TaskCompleted` fires. No pinned model.
- **Breaking:** `hc`, `orchestrate`, `implementer` and `reviewer` moved to the optional `kriskay-herdr`
  plugin (`plugins/herdr`); `./install.sh --herdr` installs them.
- **Several agents:** one `AGENTS.md` for Claude Code, Codex and OpenCode (`.claude/CLAUDE.md` moved there).
  New `delegate` skill routes work to a cheap search agent, `/batch`, a cloud session or Codex; OpenAI's
  Codex plugin for Claude Code is enabled in `examples/settings.json`. `examples/codex/` and
  `examples/opencode/` mirror the sandbox, deny rules and hooks; `install.sh --codex` links skills into
  `~/.agents/skills`.
- `examples/CLAUDE.md` is now `examples/AGENTS.example.md`, so it doesn't load as live instructions.
  Removed `examples/mcp.json`. Research behind this release in `docs/research/`; `docs/blueprint.md` lays
  the whole setup out in build order, with what's done and what's missing.

## 1.0.0 - 2026-11-16

- First public release: 13 skills, 3 agents, Java and shell rules, lint and command-log hooks, status line.
- Installable as the `kriskay-skills` Claude Code plugin from the `heykriskay` marketplace.
- `scripts/validate.sh` and GitHub Actions CI, a link check and Dependabot.
- One-click Release workflow that tags and publishes the version in `plugin.json`.
- Decision records in `docs/decisions/`.
