# kriskay-skills

Instructions for any coding agent (Claude Code, Codex, OpenCode) working in this repo.

- Check: `./scripts/validate.sh` (shellcheck, JSON, skill frontmatter, changelog, plugin validation, hook tests).
- Every change gets a line in `CHANGELOG.md` under **Unreleased**; adapted work is credited in `THIRD_PARTY_NOTICES.md`.
- `examples/` holds user-level files people merge into their own config; they don't apply to this repo.
- Skills follow the Agent Skills format (`name` + `description` frontmatter) so Codex and OpenCode can read them too.
