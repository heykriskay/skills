# kriskay-herdr

Optional add-on to [kriskay-skills](../../README.md) for people who use the
[Herdr](https://github.com/herdrdev/herdr-core) terminal app. It runs implementer and reviewer agents in
visible Herdr panes, one git worktree per feature, with you approving every commit.

Without Herdr you don't need this: Claude Code's background subagents, `isolation: worktree` and
`/batch` cover most parallel work.

## Install

```
/plugin install kriskay-herdr@heykriskay
```

Or with the copy install: `./install.sh --herdr`.

| Part | What it does |
|---|---|
| `hc` skill | Drives `hc`: start helpers and slow commands in persistent terminals, wait for reports. |
| `orchestrate` skill | Spec → plan → implementer and reviewer helpers per task → your OK on each commit. |
| `implementer`, `reviewer` agents | The worker roles `orchestrate` starts. |

## Settings

Merge these into `~/.claude/settings.json` so `hc` works inside the sandbox without prompts:

```json
{
  "permissions": {
    "allow": [
      "Bash(hc ls*)", "Bash(hc get *)", "Bash(hc read *)", "Bash(hc wait*)",
      "Bash(hc templates*)", "Bash(hc label *)", "Bash(hc kill *)", "Bash(hc rm *)",
      "Bash(hc interrupt *)", "Bash(hc --skill)",
      "Bash(herdr-app ls*)", "Bash(herdr-app status*)", "Bash(herdr-app commands*)",
      "Bash(herdr-app shot*)", "Bash(herdr-app --skill)", "Bash(herdr --skill)"
    ]
  },
  "sandbox": {
    "network": {
      "allowUnixSockets": [
        "~/.local/state/herdr-core/default/default.sock",
        "~/.config/herdr-app/herdr-app.sock",
        "~/.config/herdr/herdr.sock"
      ]
    }
  }
}
```

In CLAUDE.md, this line keeps Claude reachable while slow commands run:

```markdown
- If `HC_TERMINAL_ID` is set, run slow commands (tests, builds, installs) as
  `hc run --bg --rm --no-notify --name <n> -- <cmd>`, then `hc wait <n>`.
```
