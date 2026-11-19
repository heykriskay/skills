# Changelog

All notable changes to this project. Versions follow [Semantic Versioning](https://semver.org);
the plugin version lives in `.claude-plugin/plugin.json`.

## Unreleased

## 2.0.0 - 2026-11-19

Rebuilt around Claude Code's built-ins, following Anthropic's current guidance: put in a skill only
what Claude can't work out, and enforce checks with hooks rather than prompts.
See [docs/decisions/0006](docs/decisions/0006-lean-on-built-ins.md).

- **Breaking:** removed `grilling`, `to-spec`, `to-plan`, `execute-plan`, `test-driven-development`,
  `verification-before-completion`, `systematic-debugging`, `review-since`, `handoff` and `commit`.
  Use plan mode, `/goal`, `/code-review`, `/simplify`, `/verify`, `/compact`, `/rewind` and `/resume` instead.
- New `spec` skill: one short interview-then-write step for ambiguous features.
- New `verify` Stop hook: runs the project's check command (`.claude/verify` or `$CLAUDE_VERIFY_CMD`)
  when Claude finishes a turn that changed code, and sends failures back.
- **Breaking:** `hc`, `orchestrate`, `implementer` and `reviewer` moved to the optional `kriskay-herdr`
  plugin (`plugins/herdr`); `./install.sh --herdr` installs them with the copy install.
- `examples/settings.json`: no pinned model (default Opus 5.5 at medium effort), Herdr permissions moved
  out, Stop hook added. `examples/CLAUDE.md` cut to what Claude can't infer. Removed `examples/mcp.json`.
- `docs/research/`: the research behind this release, with sources.

## 1.0.0 - 2026-11-16

- First public release: 13 skills, 3 agents, Java and shell rules, lint and command-log hooks, status line.
- Installable as the `kriskay-skills` Claude Code plugin from the `heykriskay` marketplace.
- `scripts/validate.sh` and GitHub Actions CI, a link check and Dependabot.
- One-click Release workflow that tags and publishes the version in `plugin.json`.
- Decision records in `docs/decisions/`.
