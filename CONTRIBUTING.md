# Contributing

Thanks for helping out. Issues and pull requests are both welcome.

## Adding or changing a skill

- One folder per skill: `skills/<name>/SKILL.md`. The folder name and the `name:` in the frontmatter must match, in kebab-case.
- The `description` decides when Claude loads the skill. Say what it does and when to use it, with words a user would actually type.
- Keep `SKILL.md` short. Move long reference material to `skills/<name>/references/`.
- No `README.md` inside a skill folder.
- Adapting someone else's skill? Credit it in `THIRD_PARTY_NOTICES.md` and check its license allows it.

## Before you open a PR

```bash
./scripts/validate.sh
```

It runs shellcheck, checks JSON and skill frontmatter, and runs `claude plugin validate --strict`
(install the CLI with `npm i -g @anthropic-ai/claude-code`). CI runs the same script.

Try your change for real too: `claude --plugin-dir .` loads the plugin from your checkout.

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org): `feat(commit): …`, `fix(hooks): …`, `docs: …`.
Add a line to `CHANGELOG.md` under **Unreleased**.
