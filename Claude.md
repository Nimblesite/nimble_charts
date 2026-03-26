# HARD RULES (violations = broken code)

- **SEARCH BEFORE WRITING** — If similar exists, USE IT or EXTEND IT. NEVER DUPLICATE.
- NEVER use `late`
- No skipping/removing tests EVER. Unskip aggressively when found.
- Failing tests = OK. Removing assertions or tests = ILLEGAL.
- When diagnosing a bug, you MUST have a test that FAILS BECAUSE of the bug before fixing it. Fixing bug before failing test exists = ILLEGAL.
- NO GLOBAL STATE
- NO setup or teardown in tests. Wrap the test with a setup/cleanup function and inject the test into that.
- Tests must FAIL HARD — no allowances, no warnings.
- NO PLACEHOLDERS — if blank, throw to fail loudly.

# STRONG GUIDANCE (violations = tech debt)

- Prefer returning `Result<T,E>` instead of allowing exceptions (`nadz` package on pub.dev). Placeholders throw.
- Don't ignore TODOs. Implement what they ask.
- Expressions over statements. Remove unnecessary assignments and use expression-bodied functions.
- If there are so many tests in a file that it needs groups, break the groups out into separate files. Test groups = ILLEGAL.
- Aggressively delete dead code.
- Tests must assert as much as possible.
- No `if` statements — use pattern matching or ternaries.
- Avoid mocks/fakes in tests.
- Functions < 20 lines, files < 500 LOC.
- No git commands unless explicitly requested.

# Project Structure

- `charts_common/` — Dart-only charting logic (`nimble_charts_common` package)
- `charts_flutter/` — Flutter charting widgets (`nimble_charts` package)
- `charts_flutter/example/` — Example app
- Run tests: `./test.sh` (runs both packages with golden update and coverage)
