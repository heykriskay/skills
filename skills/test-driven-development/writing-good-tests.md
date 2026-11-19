# Writing good tests

A test earns its place by catching a specific break. Before writing the body, name the production change that would make it fail. If you can't, or only an intentional decision would (a constant's value, a message's wording), test the behaviour that depends on it instead.

## Name the break

- **Derive expected values by hand.** Literals and hand-checked fixtures, not values computed by the code under test or its helpers. Table-driven tests with literal `want` values are the preferred shape.
- **Behaviour, not text.** Run a script against controlled inputs and assert outputs, side effects or exit codes; don't grep its source.
- **Your contract, not the framework's.** Test the route you register, the query you emit, the payload you produce. Constructors, getters and plain forwarding earn tests only when they validate, default, derive or cause side effects.

## Exercise the real thing

- **Never assert on a mock.** Assert the real component's behaviour; if the mock is what you'd check, unmock it.
- **Mock at the right level.** Learn the real method's side effects first; mock the slow or external part below them and keep what the test depends on real.
- **Make doubles specific and complete.** Assert arguments, counts or order when they are part of the contract. Mock responses mirror the full real structure, not just the fields the test reads.
- **Test-only code stays in test utilities,** never as a method on a production class.
- **When mock setup outgrows the test,** switch to an integration test with real components.

## Mutation check

Before finishing, mutate the code in your head: a wrong constant or argument, the wrong branch, a missing side effect, an empty return, missing validation for zero, empty, nil or malformed input. At least one test should fail for each. One that nothing catches marks unprotected behaviour or a tautological test.
