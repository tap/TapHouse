# TapHouse

Canonical **Tap House Rules** — the shared C++ style for the Tap family of
libraries (AmbiTap, SampleRateTap, OscTap, AmbiTap-Pd, AmbiTap-Max, …).

This repo is the single source of truth for three files:

| File | Enforces |
|------|----------|
| `.clang-format` | Layout: whitespace, braces, alignment, include ordering |
| `.clang-tidy` | Identifier naming (`m_` members, `k_` constants, snake_case types/functions, PascalCase template params) **and** mandatory braces |
| `STYLE.md` | The human-readable rules and rationale |

`clang-format` and `clang-tidy` discover their config by walking **up** the
directory tree from each source file, so the two config files must live at
each consumer repo's **root**. That's why they're distributed as copies (see
below) rather than a submodule/subtree — a submodule would place them in a
subdirectory where the tools can't find them.

## Adopting the rules in a repo

1. **Sync the configs** into the repo root:
   ```sh
   git clone https://github.com/tap/taphouse
   taphouse/scripts/sync.sh /path/to/your-repo
   ```
   Commit the resulting `.clang-format`, `.clang-tidy`, and `STYLE.md`.

2. **Add the drift check** to the repo's CI so the copies can't silently
   diverge — create `.github/workflows/style.yml`:
   ```yaml
   name: Style
   on: [push, pull_request]
   jobs:
     taphouse-drift:
       uses: tap/taphouse/.github/workflows/drift-check.yml@v1
       with:
         ref: v1   # pin to a TapHouse tag; bump deliberately
   ```

## Updating the rules

Change the file(s) here, tag a new version (e.g. `v2`), then re-run
`scripts/sync.sh` in each consumer and bump the `ref:` in their `style.yml`.
Pinning to a tag (not `main`) keeps consumers from updating unexpectedly.

## Enforcement notes

- clang-format enforces layout only; naming and mandatory braces are enforced
  by clang-tidy's `readability-identifier-naming` and
  `readability-braces-around-statements`.
- `HeaderFilterRegex` only gates **header** diagnostics. Vendored third-party
  sources compiled as `.c`/`.cpp` translation units (e.g. an Ooura FFT) are
  main files and must be excluded at the **invocation** level — run clang-tidy
  only over the project's own TUs.
- `WarningsAsErrors` is intentionally not set in `.clang-tidy` so local runs
  only warn; CI passes `--warnings-as-errors=readability-*` to make the gate
  blocking.
