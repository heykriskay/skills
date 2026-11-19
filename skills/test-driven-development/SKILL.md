---
name: test-driven-development
description: Write a failing test before the code it proves. Use when implementing a feature or fixing a bug, and for every task in `execute-plan`.
---

# Test-driven development

Each behaviour starts as a test you watched fail. Skip it only for throwaway prototypes, generated code or config, and say so.

## Cycle

1. **Red:** one test for one behaviour, named after it. Run it and confirm it fails for the expected reason (the feature is missing, not a typo). A test that passes straight away tests something that already exists: change the test.
2. **Green:** the simplest code that passes. Run it again; the output should be clean.
3. **Refactor** only while green, then take the next behaviour.

A bug fix starts with a test that reproduces the bug. Code written before its test gets rewritten from a failing test, because a test written afterwards passes at once and proves nothing. If something is hard to test, simplify the interface or inject the dependency instead of skipping the test.

Before writing or changing a test, read [writing-good-tests.md](writing-good-tests.md).

The full suite runs in the Stop hook when you finish; run it yourself sooner when a change reaches beyond the code under test.
