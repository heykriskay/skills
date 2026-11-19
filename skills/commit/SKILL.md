---
name: commit
description: Propose a Conventional Commits message and commit only after the user's OK. Use whenever you are about to run git commit, or the user says /commit or "commit this".
---

# Commit

1. Look at `git status --short` and the staged and unstaged diff stats. One commit is one logical change: if the changes cover unrelated things, propose them one at a time. Leave secrets (`.env`, keys, tokens) and build output unstaged, and say so if you see any. On `main`/`master`, ask whether to branch first.
2. Show only the message, in a code block, and wait:

   ```
   <type>(<optional scope>): <summary>

   <optional body: at most 3 short lines of why>
   ```

   - Types: feat, fix, docs, refactor, test, chore, ci.
   - Summary: lowercase, imperative, no period, aim for ≤50 characters (hard limit 72).
   - Body only when the reason isn't obvious; never a file list. `!` and a `BREAKING CHANGE:` footer only for changes that break users. No AI attribution trailers.
3. After an explicit yes (an edited message counts as yes to that message): `git add <files>`, `git commit`, and show `git log --oneline -1`. If a hook fails, show its output, fix the cause and ask again.
