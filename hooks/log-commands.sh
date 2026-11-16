#!/usr/bin/env bash
#
# Appends every Bash command Claude runs to ~/.claude/bash-commands.jsonl, one
# JSON object per line: timestamp, session_id, status, cwd, tool_name, command,
# description.
# Wired to PostToolUse (ok), PostToolUseFailure (FAIL) and PermissionDenied (DENIED).
# Watch it live: tail -f ~/.claude/bash-commands.jsonl | jq
# Query it:      jq -c 'select(.status != "ok")' ~/.claude/bash-commands.jsonl

log="$HOME/.claude/bash-commands.jsonl"
umask 077 # commands can contain secrets; keep the log private

jq -c '{
  timestamp: (now | localtime | strftime("%Y-%m-%dT%H:%M:%S")),
  session_id,
  status: ({PostToolUse: "ok", PostToolUseFailure: "FAIL", PermissionDenied: "DENIED"}[.hook_event_name]
           // .hook_event_name),
  cwd,
  tool_name,
  command: .tool_input.command,
  description: .tool_input.description
}' >>"$log"
exit 0
