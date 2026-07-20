# TapHouse

Canonical **Tap House Rules** — the shared C++ style for the Tap family of
libraries (AmbiTap, SampleRateTap, OscTap, AmbiTap-Pd, AmbiTap-Max, …).

This repo is the single source of truth for four root-level config files, plus
one distributed helper script:

| File | Enforces |
|------|----------|
| `.clang-format` | Layout: whitespace, braces, alignment, include ordering |
| `.clang-tidy` | Identifier naming (`m_` members, `k_` constants, snake_case types/functions, PascalCase template params) **and** mandatory braces |
| `STYLE.md` | The human-readable rules and rationale |
| `.pre-commit-config.yaml` | Local git-hook wiring: formats staged C/C++ **before** each commit, so the clang-format CI gate can't fail on something a developer could have caught locally |
| `scripts/tidy.sh` | Local mirror of the CI **clang-tidy** gate (naming + mandatory braces) over a repo's own TUs. Distributed to C++ repos that run the clang-tidy gate; kept a single copy here so it can't fork per-repo (it was, briefly). Repo-agnostic — no project name is baked in. |

`clang-format` and `clang-tidy` discover their config by walking **up** the
directory tree from each source file, so those config files (and the
`.pre-commit-config.yaml` that drives the hook) must live at each consumer
repo's **root**. That's why they're distributed as copies (see below) rather
than a submodule/subtree — a submodule would place them in a subdirectory
where the tools can't find them.

The canonical `.pre-commit-config.yaml` pins the official
[`pre-commit/mirrors-clang-format`](https://github.com/pre-commit/mirrors-clang-format)
hook at a specific `rev` — that rev **is** the Tap-wide clang-format version,
set in one place for the whole family. This matters because an ad-hoc hook that
used each machine's own clang-format would format differently than CI and be
worse than none. Consumer CI should run this same config via
`pre-commit run --all-files` rather than a separately-installed clang-format, so
local and CI share one version by construction. (We reference the upstream
mirror rather than republishing clang-format as a TapHouse Python package — both
pull the same pinned wheel from PyPI, so the mirror is the same guarantee with
less machinery; the pin still lives here, in the synced config.)

## C++ namespaces

The family shares one top-level namespace, `tap`, with a single sub-namespace
per library (named for the library, not the domain). Nest components below that
(`tap::dsp::real_fft`, `tap::dsp::detail`). Headers live under a matching path
(`include/tap/dsp/fft.h`, included as `"tap/dsp/fft.h"`), and each library's
CMake exports an alias to match (`tap::dsp`). Preprocessor macros use the
upper-snake form of the namespace (`TAP_DSP_FFT_CMSIS`).

| Repo | Namespace | CMake alias |
|------|-----------|-------------|
| DspTap | `tap::dsp` | `tap::dsp` |
| AmbiTap | `tap::ambi` | `tap::ambi` |
| SampleRateTap | `tap::samplerate` | `tap::samplerate` |
| MuTap | `tap::mu` | `tap::mu` |
| TapTools | `tap::tools` | `tap::tools` |
| OscTap | `tap::osc` | `tap::osc` |

DspTap already follows this. The others migrate as each is next touched (e.g.
AmbiTap when it is wired to `tap::dsp`), aliasing the old namespace during
transition — a family-wide sweep is not required. This convention is recorded
here rather than in the drift-checked `STYLE.md` so it does not force a re-sync
across every repo; promote it into `STYLE.md` (a tagged release) once every
consumer has migrated and it can be enforced.

## Adopting the rules in a repo

1. **Sync the configs** into the repo root:
   ```sh
   git clone https://github.com/tap/taphouse
   taphouse/scripts/sync.sh /path/to/your-repo
   ```
   Commit the resulting `.clang-format`, `.clang-tidy`, `STYLE.md`, and
   `.pre-commit-config.yaml`.

2. **Enable the local hook** — once per clone:
   ```sh
   pipx install pre-commit   # or: pip install pre-commit
   cd /path/to/your-repo && pre-commit install
   ```
   Now `git commit` reformats staged C/C++ with TapHouse's pinned clang-format
   before the commit lands. First run fetches the pinned hook; thereafter it is
   cached and offline.

3. **Run the same hook in CI** instead of a hand-installed clang-format, so the
   version can never skew from local:
   ```yaml
   # .github/workflows/style.yml — the format gate
   - uses: actions/checkout@v4
   - uses: actions/setup-python@v5
   - run: pipx install pre-commit && pre-commit run --all-files --show-diff-on-failure
   ```

4. **Add the drift check** so the synced copies can't silently diverge — in the
   same `style.yml`:
   ```yaml
   jobs:
     taphouse-drift:
       uses: tap/taphouse/.github/workflows/drift-check.yml@v3
       with:
         ref: v3   # pin to a tag so consumers update deliberately
   ```

## Updating the rules

Change the file(s) here, tag a new TapHouse version (e.g. `v3`), then re-run
`scripts/sync.sh` in each consumer and bump the drift `ref:` in their
`style.yml`. Two independent version knobs live in this repo, both flowing to
consumers through the sync:

- **The TapHouse tag** (`v3`, `v4`, …) versions the config *files* — bumped in
  each consumer's `style.yml` `ref:`.
- **The clang-format version** is the mirror `rev:` inside
  `.pre-commit-config.yaml` — bump it *here*, and `sync.sh` carries it to every
  consumer (no per-repo edit). One place, whole family.

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
- The pre-commit hook is **clang-format only** — layout, the fast compile-free
  layer. clang-tidy stays a CI concern: it needs a compile database and
  per-TU invocation to skip vendored sources (above), which a fast pre-commit
  hook can't provide. So the hook prevents layout-gate failures locally; the
  naming/braces gate still runs in CI.
- The hook's `exclude: '^third_party/'` mirrors that same vendored-code
  boundary, and `types_or: [c, c++]` matches every C/C++ TU a repo owns.
