# Share two files, route by table, review across vendors

As of November 2026, the standard way to use Claude Code, OpenAI Codex and OpenCode together is to share **two open formats**, keep **one primary agent**, and bring the others in at fixed points. The two shared formats are **AGENTS.md** for instructions and **Agent Skills (`SKILL.md`)** for procedures. The primary agent should be Claude Code: on the harness-level Coding Agent Index v2.1, Fable 5.2 and Opus 5.5 inside Claude Code tie for first. The other agents come in through official, narrow bridges. For Claude-led work, the sanctioned bridge is OpenAI's own **`openai/codex-plugin-cc`**, which adds `/codex:review`, `/codex:adversarial-review` and `/codex:rescue` inside Claude Code. The older `codex mcp-server` bridge was **removed in September 2026**, so most 2025-era guides are now wrong. Everything else about how the agents work together is either vendor-specific or still experimental:

- MCP config, subagent definitions and hooks each use a different syntax per tool, though Codex now accepts Claude-shaped hooks.
- Agent teams and Codex multi-agent are experimental.
- No first-party router chooses between vendors.

The evidence for multi-vendor setups is thin and asymmetric. Routing reliably **saves money**, but no study shows it **raises quality** over a single strong agent. In one preprint, Claude reviewing Codex drafts helped, while Codex reviewing Claude drafts made them worse. For heykriskay/skills, that means "every step out of the loop gets a replacement" extends naturally:

- **Instructions:** AGENTS.md replaces per-tool instruction files.
- **Skills:** `~/.agents/skills` replaces per-tool skill copies.
- **Second opinion:** `/codex:adversarial-review` becomes an advisory step in the review stage.
- **Routing:** a written routing table plus pinned agent models replaces automatic routing.

Herdr and multi-vendor orchestration stay opt-in.

A note on sources. The network blocked developers.openai.com, opencode.ai, agentskills.io, agents.md and agentclientprotocol.com during research. Codex and OpenCode facts marked as source-verified come from their GitHub repositories at HEAD on 2026-11-19: `openai/codex` @ `6922926`, `sst/opencode` @ `b104f97` (v2.3.2). Facts drawn only from search-engine summaries are labelled as such. The codex-plugin-cc commands come from the plugin's README, fetched directly on 2026-11-19.

## Only AGENTS.md and SKILL.md travel across all three agents unchanged

**AGENTS.md is the instruction standard.** It is now stewarded by the Agentic AI Foundation under the Linux Foundation, and "the closest AGENTS.md to the edited file wins" ([agents.md FAQ](https://github.com/agentsmd/agents.md/blob/main/components/FAQSection.tsx)). **Claude Code has read it natively since v2.1.277**, but by default only when there is no `CLAUDE.md`, `.claude/CLAUDE.md` or `CLAUDE.local.md` in the working directory or above it. If both exist, only the CLAUDE files load. The documented sharing pattern is a `CLAUDE.md` that starts with `@AGENTS.md` and adds Claude-only lines below. If you have no Claude-only content, `ln -s AGENTS.md CLAUDE.md` works too, and neither approach loads anything twice. Claude does not read `AGENTS.override.md`, `AGENTS.local.md`, or "anything under a `.agents/` directory" ([Claude Code: Memory](https://code.claude.com/docs/en/memory#agents-md)).

The other two tools resolve instruction files differently:

- **OpenCode 2.x** reads AGENTS.md first and falls back to CLAUDE.md in any directory without one. Without a global `~/.config/opencode/AGENTS.md`, it reads `~/.claude/CLAUDE.md` ([OpenCode instructions.mdx](https://github.com/sst/opencode/blob/b104f97744fe9759082f47bcfc0170c146c23641/services/site/src/docs/content/instructions.mdx)).
- **Codex** walks from the `.git` root down to the working directory. In each directory it prefers `AGENTS.override.md`, then `AGENTS.md`, then any `project_doc_fallback_filenames`. It concatenates what it finds up to a **32 KiB budget** and skips untrusted projects entirely ([Codex agents_md.rs](https://github.com/openai/codex/blob/692292695bbacbd3e39eb3f3bf36129a94712806/codex-rs/core/src/agents_md.rs)).

Two consequences follow. Keep `@imports` out of global files, because only Claude expands them. And never put shared content in `AGENTS.override.md`. The user-level Codex path `~/.codex/AGENTS.md` is widely documented but was **not verified** in source.

**Agent Skills is the procedure standard.** A skill is a directory with `SKILL.md` and optional `scripts/`, `references/` and `assets/`. Only two frontmatter fields are required: `name` (lowercase kebab-case, **matching the directory name**) and `description` (at most 1,024 characters). `license`, `compatibility`, `metadata` and an experimental `allowed-tools` are optional. The spec lists 46 adopting clients, including Claude Code, Codex and OpenCode ([Agent Skills specification](https://github.com/agentskills/agentskills/blob/main/docs/specification.mdx); [clients](https://github.com/agentskills/agentskills/blob/main/docs/snippets/clients.jsx)).

The awkward detail is discovery. **`~/.agents/skills` and repo `.agents/skills` are the only locations both Codex and OpenCode scan natively**, and Claude Code's docs list neither. Claude needs `~/.claude/skills`, `.claude/skills` or a plugin's `skills/` directory ([Claude Code: Skills](https://code.claude.com/docs/en/skills); [Codex host_roots.rs](https://github.com/openai/codex/blob/692292695bbacbd3e39eb3f3bf36129a94712806/codex-rs/ext/skills/src/host_roots.rs); [OpenCode skills.mdx](https://github.com/sst/opencode/blob/b104f97744fe9759082f47bcfc0170c146c23641/services/site/src/docs/content/skills.mdx)). The fix is a symlink: keep skills in one directory and link it into each location.

Claude-only frontmatter is ignored elsewhere, so it is safe to keep: `disable-model-invocation`, `context: fork`, `model`, `effort`, `paths` and `hooks`. OpenCode honours `disable-model-invocation`; Codex does not. Claude-only *body* features break silently in other tools: `` !`cmd` `` injection and `$ARGUMENTS`.

The rest of the stack is not portable:

| Layer | Claude Code | Codex CLI (v0.170 / main) | OpenCode 2.x | Status |
|---|---|---|---|---|
| Instructions | `CLAUDE.md` + `@AGENTS.md`, or AGENTS.md alone | `AGENTS.md` (override first) | `AGENTS.md`, falls back to `CLAUDE.md` | **Standard** |
| Skills | `~/.claude/skills`, plugin `skills/` | `~/.agents/skills`, `.agents/skills`, `.codex/skills` | `.agents/skills`, `.claude/skills`, `.opencode/skills` | **Standard** (paths differ) |
| Subagents | `.claude/agents/*.md`, YAML | `.codex/agents/*.toml` with `developer_instructions` | `.opencode/agents/*.md`, different keys | **No shared format** |
| MCP | `.mcp.json` `mcpServers` | `[mcp_servers.x]` TOML | `mcp.servers`, command as array | Same protocol, three syntaxes |
| Hooks | `settings.json`/`hooks.json`, exit 2 blocks | `hooks.json` with Claude's event names and JSON shape | None; ordered `permissions` rules plus TS plugins | Codex is Claude-compatible; OpenCode is not |
| Sandbox | `sandbox.*`, Bash only | `sandbox_mode = "workspace-write"`, network off by default | No OS sandbox documented | Vendor-specific |
| Editor/client interop | Via Zed's `claude-agent-acp` adapter | Via `codex-acp` adapter | `opencode acp` native | **ACP is the de-facto standard** |

Sources: [Codex config.schema.json](https://github.com/openai/codex/blob/692292695bbacbd3e39eb3f3bf36129a94712806/codex-rs/core/config.schema.json); [OpenCode agents.mdx](https://github.com/sst/opencode/blob/b104f97744fe9759082f47bcfc0170c146c23641/services/site/src/docs/content/agents.mdx); [OpenCode mcp-servers.mdx](https://github.com/sst/opencode/blob/b104f97744fe9759082f47bcfc0170c146c23641/services/site/src/docs/content/mcp-servers.mdx); [ACP agents list](https://github.com/agentclientprotocol/agent-client-protocol/blob/main/docs/get-started/agents.mdx); [Claude Code: MCP](https://code.claude.com/docs/en/mcp).

Hooks are the most important finding for a plugin built on exit-2 enforcement. **Codex now ships Claude-compatible lifecycle hooks**: the events include `PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, `SubagentStop` and others, and handlers use the same `{matcher, hooks:[{type:"command", command, timeout}]}` shape. PreToolUse returns the same `permissionDecision: "deny"` payload and supports `updatedInput` ([Codex dispatcher.rs](https://github.com/openai/codex/blob/692292695bbacbd3e39eb3f3bf36129a94712806/codex-rs/hooks/src/engine/dispatcher.rs); [pre_tool_use.rs](https://github.com/openai/codex/blob/692292695bbacbd3e39eb3f3bf36129a94712806/codex-rs/hooks/src/events/pre_tool_use.rs)). Codex also ships a migrator that converts Claude `command` hooks, `.md` agents and `.mcp.json` servers into its own formats ([Codex hooks_cla.rs](https://github.com/openai/codex/blob/692292695bbacbd3e39eb3f3bf36129a94712806/codex-rs/external-agent-migration/src/hooks_cla.rs); [subagents.rs](https://github.com/openai/codex/blob/692292695bbacbd3e39eb3f3bf36129a94712806/codex-rs/external-agent-migration/src/subagents.rs)).

Three things remain **unverified**:

- whether Codex's Stop hook honours exit 2 the way Claude's does;
- whether project hooks need a trusted project;
- whether hooks sit behind a feature flag in v0.170.

There is also no Codex `TaskCompleted` event, so a "touched tests on task completion" gate has no direct equivalent. OpenCode has **no command hooks at all**. Secret-read denial becomes `{"action":"read","resource":"*.env*","effect":"deny"}` in its ordered rule list, and anything procedural needs a V2 TypeScript plugin, whose event names were not found ([OpenCode permissions.mdx](https://github.com/sst/opencode/blob/b104f97744fe9759082f47bcfc0170c146c23641/services/site/src/docs/content/permissions.mdx)).

## The Codex plugin replaced MCP bridges as the delegation path

**The verified, current way to call Codex from Claude Code is OpenAI's official plugin.** Its README (fetched 2026-11-19) documents installation with `/plugin marketplace add openai/codex-plugin-cc` and `/plugin install codex@openai-codex`, then `/codex:setup`. It requires a ChatGPT subscription or an OpenAI API key, plus Node 18.18+ ([openai/codex-plugin-cc README](https://github.com/openai/codex-plugin-cc)). The commands:

| Command | What it does |
|---|---|
| `/codex:review` | Read-only review |
| `/codex:adversarial-review` | Read-only, steerable review |
| `/codex:rescue` | Hands the task to Codex through a `codex:codex-rescue` subagent |
| `/codex:transfer` | Listed in the README |
| `/codex:status`, `/codex:result`, `/codex:cancel` | Track background jobs |

The plugin was released under Apache-2.0 on 30 March 2026 ([the-decoder](https://the-decoder.com/openai-launches-a-codex-plugin-that-runs-inside-anthropics-claude-code/)). The README fetch did not cover how `/codex:rescue` bills or how much context it hands over.

The older route is gone. **`codex mcp-server` was deprecated on 24 August 2026 and removed around CLI 0.154.0**, and `mcp-server` is no longer in the Codex CLI's subcommand enum on main ([Codex cli/src/main.rs](https://github.com/openai/codex/blob/692292695bbacbd3e39eb3f3bf36129a94712806/codex-rs/cli/src/main.rs); [Daniel Vaughan, secondhand](https://codex.danielvaughan.com/2026/08/30/codex-mcp-server-deprecated-migration-app-server-agents-sdk/)). Its replacement, `codex app-server`, speaks its own experimental JSON-RPC rather than MCP. Any guide that says `claude mcp add codex -- codex mcp-server` is out of date.

Community wrappers now shell out to `codex exec --json` instead. Some pass `--dangerously-bypass-approvals-and-sandbox`, which disables both safety layers ([glama listing](https://glama.ai/mcp/servers/briandconnelly/codex-in-claude)). Avoid those. In a small fault-injection pilot, a Codex reviewer in read-only mode still *tried* to write files in 5 of 5 trials, and only the sandbox stopped it ([arXiv 2610.10961](https://arxiv.org/html/2610.10961v1)). A reviewer's read-only status has to come from the sandbox, not the prompt.

The other directions are less settled:

- **Codex or OpenCode calling Claude.** The documented option is `claude mcp serve`, which "only exposes Claude Code's tools", not an autonomous agent ([Claude Code: MCP](https://code.claude.com/docs/en/mcp.md)). One research pass found the section and another did not, so its current status is **unverified**. A plain `claude -p` shell-out is the dependable path. Agent teams and workflows do not run under `-p`, so a shelled-out Claude behaves as a single agent ([Claude Code: Agent teams](https://code.claude.com/docs/en/agent-teams)).
- **OpenCode using Claude Code as a backend.** OpenCode can run Claude Code as its "Claude Agent" model backend (needs Claude Code ≥2.1.248). In that mode Claude's settings, CLAUDE.md, hooks, MCP servers and skills are **not loaded**, so your guardrails disappear ([OpenCode claude-agent.mdx](https://github.com/sst/opencode/blob/b104f97744fe9759082f47bcfc0170c146c23641/services/site/src/docs/content/claude-agent.mdx)).
- **ACP.** ACP lets one editor drive any of the three agents with the same UI. It does not share config, and none of the three supports A2A.

Authentication stays per vendor. Each CLI needs its own login, and cloud sandboxes need both provisioned.

## Parallel work means one worktree per agent, whatever the runner

Inside a single vendor, **subagents with a per-agent `model` are the one multi-agent feature that is standard in all three tools**. Claude Code docs say its parallel features always use Claude workers: "To involve a different tool, expose it to Claude as an MCP server" ([Claude Code: Run agents in parallel](https://code.claude.com/docs/en/agents.md)). Feature maturity by tool:

| Tool | Feature | Status |
|---|---|---|
| Claude Code | `/batch` (5–30 worktree subagents) | Bundled, standard |
| Claude Code | Dynamic workflows | GA on paid plans; up to 16 concurrent agents by default |
| Claude Code | Agent view (`claude agents`) | Research preview |
| Claude Code | Agent teams | Experimental, off by default; about **7× the tokens** in plan mode |
| Claude Code | Projects coordinator | Public beta; cloud threads ignore the repo's skills, settings and `.mcp.json` |
| Codex | Multi-agent | Sources conflict (below) |
| OpenCode | Subagents in child sessions | Standard; can mix providers per agent (`anthropic/claude-sonnet-5-5#high`) |

Sources: [Claude Code: Workflows](https://code.claude.com/docs/en/workflows.md); [Claude Code: Costs](https://code.claude.com/docs/en/costs.md); [Claude Code: Projects](https://code.claude.com/docs/en/claude-projects.md); [OpenCode agents.mdx](https://github.com/sst/opencode/blob/b104f97744fe9759082f47bcfc0170c146c23641/services/site/src/docs/content/agents.mdx).

The Codex sources disagree. Search summaries of OpenAI's docs describe multi-agent as experimental and off by default ([OpenAI: Subagents, search summary](https://developers.openai.com/codex/subagents)). Codex's config schema on main says `[agents] enabled` "Defaults to true" ([Codex config.schema.json](https://github.com/openai/codex/blob/692292695bbacbd3e39eb3f3bf36129a94712806/codex-rs/core/config.schema.json)). Treat it as **experimental** until the release notes confirm one or the other. OpenCode stands out as the only one of the three whose native agent system mixes providers.

Across vendors, the standard pattern is **one git worktree (or container) per agent, with a human reviewing each diff**. The tool on top is a UI choice, and that market is churning. Crystal was retired in February 2026. Vibe Kanban's company shut down in April and the project is now community-run. Conductor's status is unclear ([Nimbalyst comparison](https://nimbalyst.com/blog/best-agent-management-tools-2026/); [dev.to roundup](https://dev.to/stravukarl/best-tools-for-managing-parallel-ai-coding-agents-in-2026-14l8)). Two options look durable:

- **Herdr** is on the Thoughtworks Radar. It detects Claude Code, Codex and others, and tracks whether each agent is working, idle or blocked ([Thoughtworks Radar](https://www.thoughtworks.com/radar/tools/herdr)).
- **GitHub Agent HQ** is the hosted option. It runs Claude and Codex next to Copilot for Copilot Pro+ and Enterprise users, and can assign one task to several agents to compare their approaches ([GitHub blog](https://github.blog/2026-02-04-pick-your-agent-use-claude-and-codex-on-agent-hq/)).

The vendors agree on when parallelism pays off. Anthropic found multi-agent systems use about **15× the tokens of chat**, and that "most coding tasks" have "fewer truly parallelizable tasks than research" ([Anthropic Engineering](https://www.anthropic.com/engineering/multi-agent-research-system)). OpenAI likewise says subagents "consume more tokens than comparable single-agent runs" ([OpenAI: Subagents, search summary](https://developers.openai.com/codex/subagents)). Parallelize breadth work: audits, migrations, exploration and review. Keep implementation that touches shared files in one agent.

## Automatic routing remains a description field plus a static table

**No first-party or benchmarked tool picks between Claude, Codex and OpenCode by task.** In every tool, routing happens when the model reads agent `description` fields. Claude delegates "based on the request, each subagent's `description`, and current context" and warns when custom descriptions total more than 15k tokens ([Claude Code: Subagents](https://code.claude.com/docs/en/sub-agents)).

Per-request routers exist. OpenRouter's `auto-beta` takes a `cost_quality_tradeoff` setting from 0 to 10 ([OpenRouter Auto Router](https://openrouter.ai/docs/guides/routing/routers/auto-router)). But switching models mid-session invalidates the prompt cache, and Anthropic advises first measuring the best model at lower effort before building a cascade. **Pin the model per agent, not per request.**

The research on routing explains why a static table is the sensible design. An oracle router on DeepSWE would reach 97.6% at $1.88, against 74.1% at $6.52 for the best single model ([Fireworks](https://fireworks.ai/blog/llm-model-routing-deepswe)). Realistic routers capture far less of that gap. GitHub's HydraFusion "cuts AI coding costs in every benchmark; it only matches quality in one", and a LangChain benchmark found that sending 7% of calls to a frontier model cut spend by 74% at a measurable accuracy cost ([VentureBeat](https://venturebeat.com/orchestration/githubs-hydrafusion-cuts-ai-coding-costs-in-every-benchmark-it-only-matches-quality-in-one)). In practice the router is the bottleneck, so a human-written table of task types is as good as anything shipping.

The vendors' own model guidance sets the tiers. Anthropic says to "start with Claude Opus 5.5 for most coding". Fable 5.2 is for "the most ambitious, open-ended technical work" or for acting as an advisor or orchestrator. Sonnet 5.5 and Haiku 5.5 are for simpler work ([Anthropic, Fable 5.2](https://www.anthropic.com/news/claude-fable-and-mythos-5-2); [Anthropic, Sonnet 5.5](https://www.anthropic.com/news/claude-sonnet-5-5)). OpenAI keeps GPT-6.1 Sol and GPT-6 Astra for "the most complex coding work" ([OpenAI, Terra, snippet](https://openai.com/index/introducing-gpt-6-1-terra/)).

Prices line up across vendors:

| Tier | Anthropic (per MTok in/out) | OpenAI (per MTok in/out) |
|---|---|---|
| Premium | Fable 5.2, $8/$40 | GPT-6 Astra, $10/$50 |
| Default | Opus 5.5, $4/$20 | — |
| Mid | Sonnet 5.5, $2/$10 | GPT-6.1 Sol, $2/$10 |
| Bulk | Haiku 5.5, $0.10/$0.50 | GPT-6 Luna, $0.10/$0.50 |

Sources: [Help Net Security](https://www.helpnetsecurity.com/2026/09/23/gpt-6-sol-luna-lower-api-prices/); [tech-insider, secondary](https://tech-insider.org/gpt-6-astra-launch-four-ai-labs-september-2026/).

Harness and model are measured together, and the harness matters. On Artificial Analysis's Coding Agent Index v2.1 (14 Nov 2026), Fable 5.2 and Opus 5.5 **in Claude Code** tie at **58**, while GLM-5.3 in OpenCode scores about 40 ([Crypto Briefing](https://cryptobriefing.com/artificial-analysis-coding-agent-index-v2-1/); [tproger](https://tproger.ru/news/claude-fable-5-2-i-opus-5-5-vozglavili-rejting-ii-agentov-dlya-ko)). Codex's absolute v2.1 score was not found.

The routing table below is a synthesis, not a vendor document. Status shows how far each row rests on documented features.

| Task | Primary | Escalate / alternative | Why | Status |
|---|---|---|---|---|
| Everyday feature work, refactors | Claude Code, Opus 5.5 at medium | `high`/`xhigh` effort, then Fable 5.2 if Opus stalls | Anthropic's daily-driver guidance; top AA index | Standard |
| Ambiguous, long, unattended builds | Claude Code, Fable 5.2 at high/xhigh (not max) | Opus 5.5 at max | Fable leads Remote Labor Index 41.3% vs 21.3%; max effort loses AA points to timeouts | Standard (model choice) |
| Well-scoped fixes, test writing, quick edits | Sonnet 5.5 subagent, or Codex on GPT-6.1 Sol | — | "Well-scoped everyday tasks, bug fixes"; practitioners rate Codex fast on clear specs | Standard / practitioner opinion |
| Shell- and terminal-heavy loops | Sonnet 5.5 | Opus 5.5 at max | Sonnet 70.6% vs Opus 66.4% on Terminal-Bench 4.0 (vendor-reported) | Vendor benchmark |
| Search, log and test-output summarizing | Haiku 5.5 subagent (`model: haiku`) | GPT-6 Luna in Codex | Same price; Anthropic recommends Haiku for simple subagents | Standard |
| Fan-out across many files | `/batch` or a workflow, worktree per unit | Herdr panes or Agent HQ across vendors | Native, documented | Standard (native); experimental (cross-vendor) |
| Hard debugging, second hypothesis | Claude at `xhigh` | `/codex:rescue` | A different model family brings different blind spots | Plugin documented; benefit unproven |
| Code review of Claude-authored diffs | `/code-review` | `/codex:adversarial-review`, advisory only | Codex-on-Claude review lowered pass rates in one preprint | Plugin documented; benefit contested |
| Review of Codex- or OpenCode-authored diffs | Claude `/code-review` | — | Claude-on-Codex review raised pass rates from 71.6% to 89.7% | Preprint evidence |
| Cost-capped bulk work | OpenCode on OpenCode Go ($10/mo) with GLM-5.3 or DeepSeek | Haiku 5.5 / Luna | About 18 index points below the top, at a flat rate | Practitioner opinion |

Sources: [Anthropic, Fable 5.2](https://www.anthropic.com/news/claude-fable-and-mythos-5-2); [Anthropic, Sonnet 5.5](https://www.anthropic.com/news/claude-sonnet-5-5); [Claude Code: Costs](https://code.claude.com/docs/en/costs.md); [morphllm comparison](https://morphllm.com/comparisons/codex-vs-claude-code); [DEV OpenCode review](https://dev.to/jovan_chan_9500711396d4e6/opencode-review-2026-the-open-source-terminal-coding-agent-that-challenges-claude-code-5a89).

## Cross-vendor review helps in one direction and should stay advisory

Cross-vendor review now ships as a product in several places:

- `/codex:review` and `/codex:adversarial-review` inside Claude Code.
- `@codex review` on GitHub PRs, which follows AGENTS.md and reports only P0/P1 issues ([OpenAI, search summary](https://developers.openai.com/codex/use-cases/github-code-reviews)).
- Agent HQ's side-by-side agent comparisons.
- HydraFusion's "Critique" pattern, where a model from another family reviews the draft in a tool-less context.

The best quality evidence is a single preprint, and it cuts both ways. **Claude reviewing Codex drafts raised pass rates from 71.6% to 89.7%**, beating Codex self-review at 84.5%. **Codex reviewing Claude drafts lowered them from 91.4% to 82.8%** ([arXiv 2607.21656](https://arxiv.org/abs/2607.21656), not peer-reviewed). The likely explanation is that a reviewer weaker than the author adds false positives that a compliant author then "fixes".

Practitioners who use Codex to review Claude's diffs treat a disagreement as a reason to read the code, not as a vote ([Zack Proser](https://zackproser.com/blog/codex-reviews-claudes-diffs)). Claude Code's own docs make a related point: "A reviewer that's asked to find problems will always find *something*" ([Best practices](https://code.claude.com/docs/en/best-practices)).

The defensible policy has three parts. Cross-vendor review is an **advisory gate for high-risk changes**. It runs read-only in an enforced sandbox. Its findings come back to the primary agent and the human as input, and are never applied automatically. The plugin's read-only `/codex:adversarial-review` matches that policy, and `/codex:rescue` should be reserved for a stuck primary agent.

## What to change in heykriskay/skills

The repo already follows the right shape. The core is single-session, Herdr orchestration is opt-in (decision 0005), and enforcement lives in exit-2 hooks. The changes below extend each "replacement" to the other two agents without turning the plugin into a multi-vendor framework.

| # | Change | Concrete form | Status | Priority |
|---|---|---|---|---|
| 1 | Make AGENTS.md the source for global instructions | Add `examples/AGENTS.example.md`. `install.sh` links it to `~/.claude/CLAUDE.md`, `~/.config/opencode/AGENTS.md` and `~/.codex/AGENTS.md`, with no `@imports` inside. For this repo, add a root `AGENTS.md` and have `.claude/CLAUDE.md` start with `@AGENTS.md`, because `.claude/CLAUDE.md` otherwise suppresses AGENTS.md. | Standard (the Codex global path is unverified) | High |
| 2 | Publish skills to the cross-agent directory | `install.sh --agents` links each `skills/<name>` into `~/.agents/skills/` (read natively by Codex and OpenCode). Have `validate.sh` check that `name` matches the directory, `description` is ≤1,024 chars, and shared skills avoid `` !`cmd` `` and `$ARGUMENTS`. | Standard | High |
| 3 | Add Codex as an advisory reviewer | Document installing `openai/codex-plugin-cc` in the README. Have `execute-plan`, after `/code-review`, *offer* `/codex:adversarial-review` when the diff is risky (auth, migrations, concurrency, many files), and say its findings are advisory. Don't vendor or wrap the plugin, and don't add a custom Codex MCP bridge. | Plugin documented; benefit experimental | High |
| 4 | Write the routing table down instead of automating it | Add the table as `docs/decisions/0007-multi-agent-routing.md`. Keep `Explore` on `model: haiku`. Do not build a router skill: no verified one exists, and model switching breaks the cache. | Standard practice | Medium |
| 5 | Mirror the guardrails for Codex | Add `examples/codex/hooks.json`, registering `guard-kube.sh` on PreToolUse and `verify.sh full` on Stop, plus a `config.toml` snippet (`sandbox_mode = "workspace-write"`, network off, `.env` denied via a permission profile). Have `scripts/test-hooks.sh` feed Codex-shaped payloads. Or have users run Codex's built-in Claude migrator and check the output. | Experimental: Stop exit-2 semantics, tool-name matchers and feature flags unverified | Medium |
| 6 | Mirror the guardrails for OpenCode | Add `examples/opencode.json` with V2 `permissions` rules: deny `read`/`edit` on `*.env*`, `ask` on `shell` `git push*`. Note that lint and verify hooks have no OpenCode equivalent, so `AGENTS.md` must state the test command. | Standard (rules); hooks not possible | Low |
| 7 | Let Herdr's reviewer be a different vendor | In `plugins/herdr`, allow the `reviewer` pane to run `codex` with `--sandbox read-only` instead of Claude, and keep the human approval on each commit. | Experimental | Low |
| 8 | Leave out | Agent teams as a default, `codex mcp-server` recipes, wrappers using `--dangerously-bypass-approvals-and-sandbox`, OpenCode's Claude-Agent backend (it drops your hooks), and A2A. | n/a | n/a |

Each change also gets a CHANGELOG line under Unreleased, and change 3 gets a credit in THIRD_PARTY_NOTICES only if text from the plugin is adapted.

Three changes need hands-on verification before they ship:

- Change 1 depends on Codex reading `~/.codex/AGENTS.md`.
- Change 5 depends on Codex honouring exit 2 on Stop, on which tool name its shell tool matches, and on hooks being on by default in v0.170.
- Claude Code reading `.agents/skills` without a symlink is undocumented, so assume it does not.

## Conclusion

Interoperability in 2026 sits in the text layers (instructions and skills), while enforcement stays vendor-specific. That is the right split for this repo. Its value is the "replacement" for each removed human step, and only half of those replacements port. AGENTS.md and SKILL.md carry the *steering* to every agent for free. The *checking* layer ports to Codex almost verbatim, because Codex adopted Claude's hook schema, but not to OpenCode, which can only *say no* through permission rules. The practical consequence is that Claude Code stays the place where the full guardrail set holds. Codex is best brought in as a sandboxed second reader, and OpenCode as a cheap bulk executor whose output Claude reviews.

The second insight is that "automatic agent selection" is mostly a cost lever, not a quality one. The only cross-vendor quality signal so far favours a stronger model reviewing a weaker one, not the reverse. A routing table that sends bulk work down-tier and reviews up-tier captures most of the available benefit, and costs nothing to maintain except a re-read when the next model generation ships. Re-check the unverified items above at that point too, because Codex's hook semantics and multi-agent defaults are moving fastest.
