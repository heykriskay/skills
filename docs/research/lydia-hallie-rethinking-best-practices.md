# Notes: "Rethinking Claude Code Best Practices"

Lydia Hallie (Claude Code team, Anthropic), AI Engineer, November 2026, 17 minutes.
[Video](https://www.youtube.com/watch?v=vlfCjWuv4es). Summary in my own words, with timestamps.

**The idea (2:05):** we used to steer sessions, approve commands, say no, check output and start
sessions ourselves. Each step we leave needs a replacement: the model, the harness or the environment.

| Step | Replacement | How this repo does it |
|---|---|---|
| Steering (2:36) | Opus 5.5 understands intent and the codebase; CLAUDE.md keeps only what Claude can't see in the code, like a legacy source nothing references. Emphatic "IMPORTANT" lines now send it off track. `/doctor prompt-audit` finds what the model no longer needs. | Slim skills, `.claude/CLAUDE.md` with 3 lines, prompt-audit fixes |
| Approving (4:10) | Auto mode's classifier. It trusts only this folder and repo by default; describe other repos, buckets and domains in plain English in `autoMode` settings. | `autoMode.environment` in `examples/settings.json` |
| Saying no (5:44) | Auto mode blocked 89% of dangerous commands, people 14%, so about 1 in 10 still gets through. Deny rules are checked before the classifier. Test: "If Claude gets this wrong once, can I take it back?" | Deny rules for secret reads, discarding work, force-push, `rm -rf` outside the repo; `guard-kube.sh` |
| Side effects (7:18) | A deny rule sees `npm test`, not the dependency that opens `.env`. The sandbox makes the OS refuse it, for every child process. It doesn't cover Claude's own file tools, MCP servers or hooks. | Sandbox in `.claude/settings.json`, tested against a script reading `.env` |
| Environment (9:22) | Cloud sessions: own machine, fresh checkout, no local secrets; network secrets and an allowlist. Deny rules committed to the repo come along. | Project `.claude/settings.json` |
| Checking (10:56) | Pass/fail checkpoints Claude verifies on its way: in the prompt ("what done looks like, split into tasks with tests, show the output"), and guaranteed with hooks: lint on edit, touched tests on task completion, the full suite on stop. Exit 2, not 1. | `lint.sh`, `verify.sh touched` / `full` |
| Many sessions (13:31) | CI runs the same checks on every PR; CI autofix; merge when ready for low-risk changes; a fresh-context Claude review on every PR, with reviewers scaled to risk. | `validate.yml` + hook tests; see the report for CI gaps |
| Starting sessions (15:05) | One orchestrator session (Claude Code Projects, beta) splits work into threads and verifies them; Fable judges, Opus 5.5 writes. | `kriskay-herdr` add-on |

**To try (16:50):** give Claude one task much bigger than usual, make sure CI catches what you care about,
configure the cloud environment's network, secrets and setup script, then see where the session still
needs you. That is the next thing to hand over.
