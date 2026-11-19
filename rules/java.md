---
paths:
  - "**/*.java"
  - "**/pom.xml"
  - "**/build.gradle{,.kts}"
---

# Java

- Tests follow Arrange / Act / Assert. One behaviour per test, named after that behaviour.
- Cover boundary values and equivalence classes, not just the happy path.
- Prefer constructor injection and immutable fields (`final`, records) over setters.
