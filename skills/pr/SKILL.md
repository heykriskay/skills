---
name: pr
description: "Write a pull request description: summary sketch, before/after evidence, merge danger. Use whenever you open or update a PR, or the user asks for a PR body or description."
metadata:
  credits: "show-me by Dex Horthy (HumanLayer), https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md"
---

Use this template for writing the PR body:

```markdown
## Summary

<diagram, diff-sketch, or tree>

## Evidence

- **Before:** <screenshot/output/failing test run>
  **After:** <screenshot/output/passing test run>

## Merge Danger

**Door:** <one-way or two-way>

<optional: description>

**Blast Radius:** <one-word description>

<optional: potential ramifications of merge>
```

## Sections

Keep prose brief. Use the project's own terms.

### Summary

Pick the smallest view that makes the key point clear, placed next to the short text it supports: pseudocode for logic, a call tree for control flow, a shallow file tree for a refactor, a Mermaid diagram for data flow between components, or a `diff`-shaped sketch of any of these when the point is what changes. Usually one is enough; never all of them.

### Evidence

Concrete before and after evidence that the change works: a screenshot when the change is visual, otherwise test results or console output (the exact test that now passes, in pseudocode).

### Merge Danger

Describe whether it's a one-way or two-way door. You can walk back through two-way doors, but not one-way doors. A PR that is cheap to roll back is lower risk. Changes that involve destructive actions or hard-to-reverse decisions are one-way doors.

The blast radius is the potential impact or scope of the changes introduced by this PR. Examples are layout shift, breakages for consumers, mobile responsiveness, etc.
