---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development

No production code without a failing test first. If you wrote code before its test, delete it and re-implement from the test; do not keep it as reference.

Skip only for throwaway prototypes, generated code or config, and ask the user first.

## Cycle

1. RED: write one test for one behavior, with a name describing that behavior. Use real code, mocks only when unavoidable.
2. Run it and confirm it fails (not errors) for the expected reason: the feature is missing, not a typo. If it passes, it tests existing behavior: fix the test. If it errors, fix the error and re-run.
3. GREEN: write the simplest code that passes. No extra options, features or refactors beyond the test.
4. Run it. The test must pass and the output must be clean (no errors or warnings). If it fails, fix the code, not the test.
5. Run the project's full test command (`pytest`, `npm test`, `cargo test`, ...) even if the task named one file. A task scope bounds the deliverable, not verification. Report any failure it shows by name, including ones you did not cause.
6. REFACTOR only while green: remove duplication, improve names. Add no behavior. Then take the next test.

## Rules

- Bug fix: first write a test that reproduces the bug, watch it fail, then fix. Never fix a bug without a test.
- Exploration is fine, but throw it away before starting TDD.
- Hard to test means the design is too coupled: simplify the interface or inject dependencies. Do not skip the test.
- Before writing or changing any test, read [writing-good-tests.md](writing-good-tests.md): name the production change that would make it fail, assert on real behavior and not mock behavior, keep test-only code out of production classes, and understand a dependency's side effects before mocking it.
- Tests written after the code pass immediately and prove nothing. Do not rationalize ("too simple", "already tested manually", "keep as reference"). If you catch yourself doing so, stop and restart the cycle.
