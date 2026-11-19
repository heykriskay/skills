# Blueprint: this setup, built from scratch

What you would build from zero today, following the research in [docs/research](research/), in the order
that makes each step useful on its own. The rule behind all of it, from Lydia Hallie's talk: every step you
take out of the loop needs a replacement.

| You used to | Now | Enforced by |
|---|---|---|
| Steer | The model, plus instructions it can't infer | Short `AGENTS.md`, slim skills |
| Approve | Auto mode | `autoMode.environment` |
| Say no | Deny rules and the sandbox | Harness and operating system |
| Check | Hooks and CI | Exit code 2, required PR checks |
| Start sessions | A lead session that delegates | `delegate` skill, cloud sessions |

## Build order

Status: **done** is in this repo and tested; **partial** exists but isn't verified end to end; **gap** is not built.

### 1. Environment, before any code

A cloud session per task: a fresh machine, no local secrets, network limited to package registries and
GitHub plus the hosts you add. Keys go in as network secrets, never in the repo or the prompt. A setup script
installs what the hooks and sandbox need.

| Piece | Status |
|---|---|
| Cloud environment with an allowlist (`skills`: YouTube, AI Engineer, OpenAI and OpenCode docs) | done |
| Setup script: `bubblewrap` and `socat` for the sandbox, `shellcheck` for the lint hook | partial: saved on the environment, runs from the next fresh container |
| Network secrets for API keys (Codex, others) | gap: none needed yet |

### 2. Instructions: only what the code can't tell

| Piece | Where | Status |
|---|---|---|
| One instruction file for every agent | `AGENTS.md`; `.claude/CLAUDE.md` is just `@../AGENTS.md` | done |
| Global preferences, linked into each tool | `examples/AGENTS.example.md` | done |
| Path-scoped rules that load only for matching files | `rules/` | done |
| An audit after every model upgrade | `/doctor prompt-audit` | done (run once, fixes applied) |

No emphatic wording, no stack descriptions, no "keep going": current models over-apply them.

### 3. Safety: decide by reversibility

"If Claude gets this wrong once, can I take it back?" If yes, leave it to auto mode. If no, write a rule.

| Piece | Where | Status |
|---|---|---|
| Auto mode by default, bypass disabled | user settings | done |
| Trusted repos, registries, which clusters are remote | `autoMode.environment` (user settings only) | done (confirmed with `claude auto-mode config`) |
| Deny secret reads, discarding work, force-push, `rm -rf` outside the repo | `.claude/settings.json`, committed | done |
| Block delete/apply on non-local clusters | `hooks/guard-kube.sh` | done (tested) |
| OS sandbox: no `.env`, `~/.ssh` or tokens; network allowlist | `.claude/settings.json` | done (tested: `Permission denied: '.env'`) |
| `git commit` and `git push` outside the sandbox, for signing and auth | `sandbox.excludedCommands` | done (found by running under it) |

The sandbox covers shell commands only. Claude's own file tools, MCP servers and hooks run outside it,
which is why the deny rules stay.

### 4. Checks: what must run, runs

| When | Hook | Status |
|---|---|---|
| After each edit | `lint.sh`: shell, YAML, Go, Python, JS/TS | done |
| A task is marked complete | `verify.sh touched`: tests for the changed files | done |
| Claude stops | `verify.sh full`: the whole suite, until it passes | done (tested end to end) |
| The hooks themselves | `scripts/test-hooks.sh` in `validate.sh` | done (mutation-checked) |
| Every PR | the same checks in CI | done |
| CI installs every toolchain the hook tests use | `validate.yml` | gap: Python and JS fixtures can be skipped on the runner |
| A fresh-context Claude review on every PR, with CI autofix | GitHub workflow or cloud auto-fix | gap |
| Merge when ready for low-risk changes | branch protection | gap (your decision) |

Every hook exits 2 on failure; exit 1 would let Claude carry on.

### 5. Workflow: your process as short skills

`spec` → `to-plan` → `execute-plan` (test first, `commit` per task) → `/code-review` → `pr`. Status: done.
Each skill says only what the model wouldn't do on its own: the file layout of a spec and plan, when to stop
and ask, the commit format, the PR template.

### 6. Delegation: one lead, other agents advise

| Work | Goes to | Status |
|---|---|---|
| Search | `Explore` agent on haiku | done |
| One change across many files | `/batch` | built in |
| Long or ambiguous | `claude --cloud`, with a `/goal` | built in |
| Risky design, second opinion | `/codex:adversarial-review` (read-only, advisory) | partial: plugin enabled, not run here |
| Independent attempt when stuck | `/codex:rescue --background` | partial |
| Coordinating many sessions | Claude Code Projects (beta): Fable leads, Opus 5.5 writes | gap: Herdr add-on instead |

### 7. Other agents read the same setup

| Piece | Status |
|---|---|
| Codex: `config.toml` (workspace-write sandbox, no network), `hooks.json` reusing the same scripts | partial: schema-valid, not run in Codex |
| OpenCode: permission rules mirroring the deny list | partial: not run in OpenCode |
| Skills in `~/.agents/skills` for Codex (`install.sh --codex`) | done |

## What we'd leave out

- An automatic model router: it saves money but no study shows better results, and it breaks the prompt cache.
- MCP bridges between agents: `codex mcp-server` is gone; use the official plugin.
- Agent teams by default: experimental, and several times the tokens.
- Process skills for things the model does well: debugging method, "verify before done", hand-offs.

## Still to do

1. CI: install `pytest` and Node on the runner so no hook test is skipped; add a Claude review on PRs.
2. Try the parts this cloud session can't: Code Mode, an interactive `claude --plugin-dir .` run, Codex and
   OpenCode with their example configs.
3. Give one large task to a cloud session and note where it still needs you. That's the next thing to hand over.
