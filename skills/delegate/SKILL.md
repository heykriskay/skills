---
name: delegate
description: "Decide whether a task, or part of one, should go to another agent or model (a subagent, a parallel batch, Codex, a cloud session) and hand it off. Use when work splits into independent parts, needs a second opinion from another vendor, is bulk or mechanical, will run for hours, or you are stuck after two attempts."
---

# Delegate

Doing the work in this session is the default: it already has the context, and every extra agent costs tokens (Anthropic measured multi-agent runs at about 15× a chat). Hand off only when one of the rows below fits.

| The work | Send it to | How |
|---|---|---|
| Find code, read logs, answer "where/how does X work" | Search subagent on a cheap model | The `Explore` agent (haiku) |
| One change repeated across many files or packages | Parallel subagents, one worktree each | `/batch <change>` |
| Independent tasks from a plan that touch different files | Background subagents | Agent tool with `isolation: worktree` |
| Long, ambiguous or unattended work | A cloud session, Fable 5.2 for the hardest | `claude --cloud "<task>"`; give it a `/goal` |
| A second opinion on a risky design before it ships | Codex, read-only | `/codex:adversarial-review --base main <the risk>` |
| An independent attempt after two failed fixes | Codex, in the background | `/codex:rescue --background <the problem>` |
| A routine review of the finished branch | Claude first, then Codex | `/code-review`, then `/codex:review --base main --background` |

Codex commands come from OpenAI's `codex` plugin for Claude Code (`/plugin install codex@openai-codex`, then `/codex:setup`). If they aren't installed, use the Claude row above it and say so.

## Rules for any hand-off

- Give the other agent what it can't see: the spec or plan path, the files it may touch, and the command that proves it's done.
- Never let two agents edit the same working tree. Parallel writers each get a worktree.
- Another vendor advises; you decide. Check each point it raises against the code before changing anything. Cross-vendor review helps in one direction and hurts in the other, so don't apply its fixes blindly.
- Read the result yourself: the diff and the test output, not the agent's summary. The hooks still run on whatever comes back.
- Tell the user in one line where you sent what, and why.
