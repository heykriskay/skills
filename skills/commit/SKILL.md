---
name: commit
description: Commit changes safely - propose a Conventional Commits message and commit only after the user's explicit OK. Use whenever you are about to run git commit, or the user says /commit or "commit this".
---

# Commit

Never commit without the user's explicit OK on this exact message.

## 1. Look

```bash
git status --short
git diff --stat
git diff --cached --stat
```

- If nothing is staged, decide which files belong together: one commit = one logical change. If the changes cover unrelated things, say so in one line per commit, then propose and do them one at a time.
- Never stage secrets (`.env`, keys, tokens) or build output. If you see one, stop and say so.
- If on `main`/`master`, ask whether to branch first.

## 2. Propose

Show the user only the message, in a code block. No file list, no diff commands, no preview of later commits: the user reads the diff in their IDE.

```
<type>(<optional scope>): <summary>

<optional body: at most 3 short lines of why>
```

- Types: feat, fix, docs, refactor, test, chore, ci.
- Summary: lowercase, imperative, no period, aim for ≤50 chars (hard limit 72).
- Body: leave it out by default. Add one only when the reason isn't obvious, 1-3 lines. Never list files or narrate the diff. Needs more? It's probably several commits.
- Scope: the app or area when it helps, e.g. `feat(api): …`.
- `!` after the type plus a `BREAKING CHANGE:` footer only for changes that break users.
- No AI attribution trailers.

Then stop and wait.

## 3. Commit

Only after an explicit yes (an edited message counts as a yes to that message):

```bash
git add <files>
git commit -m "<summary>" [-m "<body>"]
git log --oneline -1
```

Show the `git log` line. If a hook fails, show its output, fix the cause, and ask again.
