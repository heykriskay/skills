---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

Save it next to the feature's other files: `specs/YYYY-MM-DD-<slug>-context.md` at the repo root, reusing the date and slug of the feature's `-design.md` if one exists (else today's date and a new slug). Overwrite an older context file for the same feature; it is the current state, not a log. Outside a git repo, save to `$TMPDIR` (else `/tmp`) instead.

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead. For a plan, say which tasks are ticked and which is next.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information. The file is committed, so this matters.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
