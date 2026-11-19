# Delete the scaffolding, keep the guardrails

As of November 2026, Anthropic's guidance is that **an untuned Claude Code session already does the right thing for most prompts**. Your setup only needs to supply what the model can't see in the code: a short CLAUDE.md with commands and gotchas, a few deterministic checks (hooks that exit 2, deny rules, the sandbox), and a definition of "done" that Claude can run itself ([Best practices](https://code.claude.com/docs/en/best-practices)). The official docs now include a "What you can stop doing" table. It retires IMPORTANT/ALL-CAPS emphasis, "keep going / don't be lazy" lines, "think harder" phrasing, describing the architecture in CLAUDE.md, aggressive context management, and using subagents "for a better answer" ([Best practices](https://code.claude.com/docs/en/best-practices)). The defaults have moved the same way. **Auto mode is the starting permission mode** for interactive sessions (v2.1.283+), and **Opus 5.5 at medium effort** is the default model ([Permission modes](https://code.claude.com/docs/en/permission-modes); [Model config](https://code.claude.com/docs/en/model-config)). Planning, review, cleanup, security review, app verification, run-until-done (`/goal`), parallel migrations (`/batch`), polling (`/loop`, Monitor) and prompt auditing (`/doctor prompt-audit`) all ship as built-ins. That makes **at least 10 of the 13 process skills in heykriskay/skills redundant**. The rest reduce to a couple of thin, repo-specific recipes plus a hooks file. One caveat on sources: Lydia Hallie's Nov 11 "Rethinking Claude Code Best Practices" talk could not be fetched directly, so claims attributed to it come from secondhand summaries. They match the official best-practices page closely.

## CLAUDE.md shrinks to about 8 lines of facts the repo can't tell Claude

The official test for each line is two questions: "Could it find this by reading the code? Would it actually go and look? If both are yes, leave it out" ([Best practices](https://code.claude.com/docs/en/best-practices)). What survives falls into **four categories**:

1. Exact test, typecheck and lint commands, including how to run a single test.
2. Places where the code misleads, such as an old pattern new code must not copy.
3. Decisions that aren't recorded in the repo.
4. "Anything you've had to correct twice already."

The docs' sample file is about eight lines under the headings Commands, Conventions and Gotchas. They call the test command "the single most useful line" ([Best practices](https://code.claude.com/docs/en/best-practices)). The hard ceiling is **under 200 lines per file**. `@imports` don't reduce context cost. Path-specific guidance belongs in `.claude/rules/*.md` with a `paths:` filter, and workflows belong in skills, which load only when invoked ([Memory](https://code.claude.com/docs/en/memory); [Maximizing session value](https://claude.com/resources/articles/maximizing-the-value-of-your-claude-code-sessions)).

Emphasis now backfires. Current models "follow a plainly worded line, and piling on emphasis mostly makes Claude over-apply the rule." If a line keeps getting ignored, the docs' diagnosis is that "the line belongs in a hook." The reverse also holds: hooks that only encode preferences should be deleted ([Best practices](https://code.claude.com/docs/en/best-practices)). One phrase still earns its place, **"be ambitious"**, because Claude otherwise "build[s] the smallest thing that satisfies" the request ([Best practices](https://code.claude.com/docs/en/best-practices)).

To audit an existing setup, run **`/doctor prompt-audit`** (v2.1.283+). It scans CLAUDE.md, AGENTS.md, rules, skills, commands, subagents and output styles for "instructions written for older models, references to files or commands that don't exist, and files that contradict each other." It proposes edits and changes nothing until you approve them ([Memory](https://code.claude.com/docs/en/memory)). Plain `/doctor` also flags CLAUDE.md content Claude could derive from the code, along with unused skills and MCP servers and what each costs in context ([Skills](https://code.claude.com/docs/en/skills)). For a plugin repo, the useful check is `/doctor prompt-audit skills/<name>`, run on each remaining skill. Two plugin limits matter here. A plugin-root CLAUDE.md is **not loaded**, so anything it needs to say has to go in a skill ([Plugin manifest](https://code.claude.com/docs/en/plugins/manifest-reference)). And skills follow the same rule as CLAUDE.md: only write down what Claude can't find on its own ([Best practices](https://code.claude.com/docs/en/best-practices)).

## Built-ins now cover planning, review, verification and orchestration

The table below lists the built-ins that overlap with process skills. Bundled skills are prompt-based and can be turned off with `disableBundledSkills` ([Skills](https://code.claude.com/docs/en/skills)).

| Built-in | What it replaces | Source |
|---|---|---|
| Plan mode (`Shift+Tab`, `/plan <task>`) | Plan-then-approve chains. A read-only Plan subagent researches, plans are saved to `~/.claude/plans/` (or `plansDirectory`), `Ctrl+G` edits the plan, and approving switches into auto mode. | [Permission modes](https://code.claude.com/docs/en/permission-modes) |
| AskUserQuestion plus the prompt "Interview me until you could write the spec, then write it to SPEC.md" | Grilling and spec skills | [Best practices](https://code.claude.com/docs/en/best-practices) |
| `/goal <condition>` | "Keep going until done" execution loops. A separate model checks the condition after every turn. | [Goal](https://code.claude.com/docs/en/goal) |
| `/code-review [low…max\|ultra] [--fix] [--comment]` (`/review` is an alias) | Correctness review. Runs in a fresh forked subagent and follows CLAUDE.md. | [Code review](https://code.claude.com/docs/en/code-review-local) |
| `/simplify` | Cleanup/DRY review. Four parallel agents check reuse, simplification, efficiency and abstraction level. | [Commands](https://code.claude.com/docs/en/commands) |
| `/security-review` | Security pass over the branch diff against origin's default branch | [Commands](https://code.claude.com/docs/en/commands) |
| `/verify`, `/run` | "Verify before completion." Builds and runs the app, and can record a project `verify` skill. | [Skills](https://code.claude.com/docs/en/skills) |
| `/batch` | Fan-out orchestration. Splits work into 5–30 units, each run by a background subagent in its own worktree that opens its own PR. | [Commands](https://code.claude.com/docs/en/commands) |
| `/loop`, Monitor | Babysitting PRs and CI, and polling | [Scheduled tasks](https://code.claude.com/docs/en/scheduled-tasks) |
| Dynamic workflows (`ultracode`, `/workflows`) | Skills that spawn N subagents. The docs explicitly offer to convert "a skill that fans work out" into a workflow. | [Workflows](https://code.claude.com/docs/en/workflows) |
| `claude -w`, `isolation: worktree`, `/fork`, `/rename` + `/resume` | Manual worktree and handoff management | [Worktrees](https://code.claude.com/docs/en/worktrees); [Commands](https://code.claude.com/docs/en/commands) |
| Auto memory | "Remember this" and lessons-learned files | [Memory](https://code.claude.com/docs/en/memory) |

Three details change how a plugin should be written.

First, the **Task tools are off by default on current models**, because "Claude keeps track of multi-step work without a written checklist." Skills that maintain TODO or progress files go against the grain ([Tools reference](https://code.claude.com/docs/en/tools-reference)).

Second, **subagents start in the background by default** (v2.1.198+), and forks inherit the conversation (v2.1.232+). Older skills that say "spawn X and wait" may now behave differently ([Sub-agents](https://code.claude.com/docs/en/sub-agents)).

Third, a **project or personal skill named exactly `verify` or `simplify`** is run automatically before each commit (v2.1.286+). Bundled and plugin skills don't get this hook-in ([Skills](https://code.claude.com/docs/en/skills)). A personal plugin therefore can't supply the pre-commit `verify` itself. Each repo should record its own with `/verify`.

The docs' spec workflow still exists, but in a lightweight form. Interview Claude into a SPEC.md, start a fresh session to build from it, then ask a subagent to review the diff against the spec and to "skip style". Keep that instruction: "A reviewer that's asked to find problems will always find *something*" ([Best practices](https://code.claude.com/docs/en/best-practices)). Plan mode is no longer presented as a mandatory step. Boris Cherny's January 2026 thread described starting most sessions in plan mode and then auto-accepting edits, with 5 local and 5–10 web sessions running in parallel ([Boris Cherny on X](https://x.com/bcherny/status/2007179833990885678); [paddo.dev](https://paddo.dev/blog/how-boris-uses-claude-code/)). That thread predates Opus 5.5 and auto mode, so treat it as historical. It remains useful for the parallelism pattern and for its shared, git-checked CLAUDE.md that teammates update during review.

## Hooks enforce "done", and only exit code 2 blocks

Claude "stops when the work looks done". Without a check it can run, "you [are] the test suite" ([Best practices](https://code.claude.com/docs/en/best-practices)). The official ladder runs from weakest to strongest:

1. A prompt ("run the auth tests, keep going until they pass").
2. `/goal`.
3. A **Stop hook that exits 2**.
4. A fresh-context reviewer (`/code-review` or a subagent).

Whichever level you use, ask Claude for evidence, meaning the command it ran and that command's output ([Best practices](https://code.claude.com/docs/en/best-practices)).

Exit codes are the most common mistake. **Exit 1 is a non-blocking error.** "If your hook is meant to enforce a policy, use `exit 2`" ([Hooks](https://code.claude.com/docs/en/hooks)). Exit 2 has a different effect on each event. On `Stop` it prevents stopping. On `TaskCompleted` it keeps the task open. On `PreToolUse` it blocks the call. On `PostToolUse` it only shows stderr to Claude, because the tool has already run. Use `onFailure: "block"` (v2.1.295+) so that a crashing hook fails closed ([Hooks](https://code.claude.com/docs/en/hooks)).

The docs' minimal Stop gate is `pnpm tsc --noEmit 1>&2 || exit 2`. Command scripts should also guard on `stop_hook_active` so they don't loop forever. Claude Code has its own backstop: it overrides the block after **8 consecutive blocks**, configurable with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` ([Best practices](https://code.claude.com/docs/en/best-practices); [Hooks guide](https://code.claude.com/docs/en/hooks-guide)). The official TaskCompleted example is `if ! npm test 2>&1; then echo "Tests not passing..." >&2; exit 2; fi` ([Hooks](https://code.claude.com/docs/en/hooks)). A blocking Stop hook makes every turn wait for the suite. For long suites, the documented **async PostToolUse** test hook or a TaskCompleted gate costs less ([Hooks](https://code.claude.com/docs/en/hooks)).

Two other recipes are worth shipping:

- A `PostToolUse` formatter on `Edit|Write`. The docs' reasoning: "whether Claude remembers the rule no longer matters."
- A `PreToolUse` hook that rewrites `npm test|pytest|go test` with `updatedInput` to pipe through `tail -n 100`, keeping test logs out of context.

([Best practices](https://code.claude.com/docs/en/best-practices); [Costs](https://code.claude.com/docs/en/costs)).

`prompt` and `agent` hooks ask another model to decide, so they aren't deterministic. Use `command` or `http` hooks for anything that must hold ([Best practices](https://code.claude.com/docs/en/best-practices)). In a plugin, `hooks/hooks.json` must wrap the event map in a top-level `"hooks"` key, or the file fails to load. Use exec form or double-quote `"${CLAUDE_PLUGIN_ROOT}"` ([Plugins reference](https://code.claude.com/docs/en/plugins-reference)). Keep the enforced set small: "If you ever find yourself at forty of them, most are probably preferences" ([Best practices](https://code.claude.com/docs/en/best-practices)).

## Auto mode replaces click-through approval, and deny rules hold the absolutes

Anthropic made auto mode the default on Aug 14, 2026. In its testing, the classifier **caught 89% of dangerous commands; manual approval caught 14%** ([ClaudeDevs on X](https://x.com/ClaudeDevs/status/2085794862608318627)). Secondhand coverage says human catch rates dropped from about 17% early in a session to about 5% after 50+ prompts ([Pondero Brief](https://buttondown.com/ponderoai/archive/pondero-brief-claude-code-auto-mode-blocks-89-of/)). The docs agree: after the tenth prompt "you start approving without reading" ([Best practices](https://code.claude.com/docs/en/best-practices)).

Auto mode is still a judgment call. It runs on a Sonnet 5 classifier, falls back to prompting after 3 consecutive or 20 total blocks, and drops broad allow rules such as `Bash(*)` while it is active. A boundary you only state in chat can be lost to compaction ([Permission modes](https://code.claude.com/docs/en/permission-modes)). **"Never" rules therefore belong in `permissions.deny` or hooks**, which apply in every mode and run before the classifier. Tune routine blocks with `autoMode.allow/soft_deny/environment` in user settings, and always keep `"$defaults"` in each list ([Best practices](https://code.claude.com/docs/en/best-practices); [Settings](https://code.claude.com/docs/en/settings-reference)). `defaultMode: "auto"` is ignored in project `.claude/settings.json`. A plugin can only document it as a snippet for user settings ([Permission modes](https://code.claude.com/docs/en/permission-modes)).

The **sandbox is off by default** and covers Bash only. Read/Edit, hooks, MCP servers and the statusline all run outside it. Its defaults also allow reads of `~/.ssh` and `~/.aws/credentials`, so add `sandbox.credentials` deny entries. The docs say "There is no built-in credential deny list." `autoAllowBashIfSandboxed` **changed its default to `false` in v2.1.324**, so set it explicitly. Setting `allowUnsandboxedCommands: false` gives strict mode ([Sandboxing](https://code.claude.com/docs/en/sandboxing); [Settings](https://code.claude.com/docs/en/settings-reference)). A reasonable personal baseline:

- auto mode, set in user settings;
- deny rules for `Read(./.env)` and `Read(./secrets/**)`;
- an ask rule for `Bash(git push *)`;
- the sandbox enabled with credential denies;
- human sign-off at merge rather than per command.

`bypassPermissions` is only for disposable containers ([Best practices](https://code.claude.com/docs/en/best-practices)).

## Models, effort, subagents and context

**Model and effort.** Leave the model at the default, **Opus 5.5 at medium effort**. The docs say Opus 5.5 at medium "matches or exceeds Opus 5 at `high`" ([Model config](https://code.claude.com/docs/en/model-config)). Raise effort to `high` or `xhigh` for subtle bugs, flaky tests and schema changes. Use `low` for quick back-and-forth. Use `max` only for hard unattended problems, because it "tends to overthink". Use Fable 5.2 (`/model fable`) for long, ambiguous work: "describe the outcome, not the steps" and "skip the verification reminders" ([Best practices](https://code.claude.com/docs/en/best-practices); [Model config](https://code.claude.com/docs/en/model-config)). Hallie's guidance has two halves. If Claude had all the context and still got it wrong, use a bigger model. If it skipped a file or didn't run the tests, raise effort ([Model and effort blog](https://claude.com/blog/claude-model-and-effort-level-in-claude-code)). Persist effort per model with `modelSettings`, because a top-level `effortLevel` in user settings is ignored by Opus 5.5. `ultrathink` raises a single turn to `xhigh`. Set the model before you start, because switching models invalidates the prompt cache; changing effort on 5.5-generation models does not ([Model config](https://code.claude.com/docs/en/model-config); [Prompt caching](https://code.claude.com/docs/en/prompt-caching)).

**Subagents.** Subagents **inherit the parent model**. Built-in Explore stopped using Haiku in v2.1.198 and now inherits the parent's model too ([Sub-agents](https://code.claude.com/docs/en/sub-agents)). Pin `model: haiku` on agents that do mechanical work such as log summaries or test runs. Give reviewers read-only tools (`Read, Grep, Glob`). To make exploration cheap, define a custom agent named `Explore` with `model: haiku` ([Sub-agents](https://code.claude.com/docs/en/sub-agents); [Best practices](https://code.claude.com/docs/en/best-practices)). Delegation alone "doesn't make the answer any better", and it can be slower. Use subagents for parallelism, for keeping noisy output out of the main context, and for a fresh reviewer ([Best practices](https://code.claude.com/docs/en/best-practices)).

**MCP and context.** MCP tools are **deferred by default** (tool search). Prefer CLIs like `gh` over MCP where one exists, and disable unused servers in `/mcp` ([Costs](https://code.claude.com/docs/en/costs)). Use `/clear` between tasks. Run `/compact` before breaks, because the cache lasts about 1 hour on a subscription and 5 minutes on an API key. Prefer `/rewind` to `/compact` when you can, and use `/context` and `/usage` to find skills and servers that cost a lot ([Maximizing session value](https://claude.com/resources/articles/maximizing-the-value-of-your-claude-code-sessions)). Skills set to `disable-model-invocation: true` cost no context until you invoke them. Model-invocable skills add a description to the listing on every turn ([Skills](https://code.claude.com/docs/en/skills)).

## Mapping the 13 old skills to modern replacements

| Old skill | Modern replacement | Keep a custom skill? |
|---|---|---|
| grilling | AskUserQuestion, triggered by "Interview me until you could write the spec" | No |
| to-spec | Same interview prompt, writing to SPEC.md | Only for a team-specific spec template |
| to-plan | Plan mode / `/plan` (plan files, `Ctrl+G` to edit) | No |
| execute-plan | Approve the plan, which switches into auto mode; add `/goal "all acceptance criteria in SPEC.md hold"` | No |
| TDD | Ask for a failing test first in the prompt; enforce with a Stop or TaskCompleted hook that exits 2 | No (hook instead) |
| verification-before-completion | Stop/TaskCompleted exit-2 hook, `/verify`, `/goal`, and asking for evidence | No; each repo records its own `verify` skill |
| systematic-debugging | Plain prompt at `high`/`xhigh` effort, or Fable for hard cases | No |
| review-since | `/code-review <branch\|range>`, `/simplify`, `/security-review` | No |
| commit | Built-in commit flow; per-repo `verify`/`simplify` skills run before each commit; `attribution` setting | Only for unusual commit conventions (`disable-model-invocation: true`) |
| pr | Built-in commit/PR flow via `gh`, `/code-review --comment`, `/loop` to babysit | Optional thin recipe if your PR template is unusual |
| handoff | `/rename` + `/resume`, `/fork`, auto memory, plan/SPEC files | No |
| hc | Not described in the notes; check it against `/doctor` (setup checkup) | Re-evaluate |
| orchestrate | `/batch`, dynamic workflows, background subagents with `isolation: worktree` | No (convert to a saved workflow if bespoke) |

What the plugin should hold after the refactor:

- `hooks/hooks.json` with a Stop or TaskCompleted test gate that exits 2 and checks `stop_hook_active`, an edit-time formatter, and the test-output trimmer.
- Optional agent files that pin `model: haiku` for mechanical jobs.
- A statusline showing model, effort, context % and cache warmth.
- Documented user-settings snippets for auto mode, deny rules and the sandbox.

Run `/doctor prompt-audit` on anything that survives.

## Conclusion

Anthropic's own guidance now expects a "best practices" kit to shrink as models improve. The docs say outright that advice which "starts to feel like busywork" belongs in the stop-doing table ([Best practices](https://code.claude.com/docs/en/best-practices)). A process-skill plugin therefore works against the main trend: most of what it encoded has moved into the model's own judgment, the built-in commands, and the harness's deterministic layer. What a personal plugin can still uniquely provide is **enforcement and environment**, meaning exit-2 hooks, safe-default settings snippets, cheap subagent definitions and a cost-aware statusline. It no longer needs to provide methodology.

Two uncertainties remain. Hallie's talk has not been verified first-hand. Built-in behavior also changes quickly: `/code-review`'s auto-invocation flipped twice between v2.1.215 and v2.1.246, and `autoAllowBashIfSandboxed` changed its default in v2.1.324 ([CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)). Pin any version-gated behavior the plugin depends on with `engines` in plugin.json, and re-run `/doctor prompt-audit` after major Claude Code upgrades.
