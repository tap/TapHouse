# TapHouse

Canonical **Tap House Rules** — the shared C++ style for the Tap family of
libraries (AmbiTap, SampleRateTap, OscTap, AmbiTap-Pd, AmbiTap-Max, …).

This repo is the single source of truth for four root-level config files, plus
two distributed helper scripts and each repo's icons:

| File | Enforces |
|------|----------|
| `.clang-format` | Layout: whitespace, braces, alignment, include ordering |
| `.clang-tidy` | Identifier naming (`m_` members, `k_` constants, snake_case types/functions, PascalCase template params) **and** mandatory braces |
| `STYLE.md` | The human-readable rules and rationale |
| `.pre-commit-config.yaml` | Local git-hook wiring: formats staged C/C++ **before** each commit, so the clang-format CI gate can't fail on something a developer could have caught locally |
| `scripts/tidy.sh` | Local mirror of the CI **clang-tidy** gate (naming + mandatory braces) over a repo's own TUs. Distributed to C++ repos that run the clang-tidy gate; kept a single copy here so it can't fork per-repo (it was, briefly). Repo-agnostic — no project name is baked in. Its verdict is self-tested here by `scripts/test-tidy.sh` (TapHouse CI, `test.yml`; not synced), which drives the script with a fake clang-tidy and multi-megabyte output — the old `printf \| grep -q` predicate under `pipefail` reported "clean" over real warnings once the output outgrew the pipe buffer. |
| `.claude/hooks/session-start.sh` | Claude Code **web** sessions: fresh containers clone bare (no submodules, no pre-commit hook), so agent commits could bypass the local format layer entirely. The hook initializes submodules, installs the pinned pre-commit hook, and warms its clang-format at session start. Registered per-repo by `.claude/settings.json` (created by sync only if missing — repos may extend their settings, so only the hook *script* is drift-guarded). |
| `.github/pull_request_template.md` | The family's shared review prompts: what changed and why, **verification** (what was actually run versus what CI will gate, and the measured-not-remembered rule for performance claims), and a delete-what-does-not-apply list of the recurring cross-repo concerns — contract changes, submodule pin flow, notebook re-execution, package docs/help + universal binaries. Created by sync **only if missing** and deliberately **not** drift-guarded: it is prose for humans, and repos legitimately tailor it. |
| Icons: `.github/icon-{light,dark}.svg`, `book/theme/favicon.{svg,png}`, `icon.png` | The repo's mark from [`brand/`](brand/README.md): the README header in every repo, the favicon of a repo's mdBook, a Max package's icon in Max. Which of them a repo carries follows from its shape (`scripts/icon-files.sh`). Synced **only on request** (`sync.sh --icon <Library>`) and drift-guarded only where the caller names the library (`icon:`), since a repo needs a mark first. Compared byte for byte. |

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

The family's icons and palette live in [`brand/`](brand/README.md). Apart from
each repo's own icons (above), they are not synced or drift-checked.

## C++ namespaces

The family shares one top-level namespace, `tap`, with a single sub-namespace
per library (named for the library, not the domain). Nest components below that
(`tap::dsp::real_fft`, `tap::dsp::detail`). Headers live under a matching path
(`include/tap/dsp/fft.h`, included as `"tap/dsp/fft.h"`), and each library's
CMake exports an alias to match (`tap::dsp`). Preprocessor macros use the
upper-snake form of the namespace (`TAP_DSP_FFT_CMSIS`).

The three columns are independent, and they have migrated at different rates —
the table records the target, and the "Header path" column is the one still
lagging, because changing it is a breaking change for every consumer.

| Repo | Namespace | CMake alias | Header path |
|------|-----------|-------------|-------------|
| DspTap | `tap::dsp` | `tap::dsp` | `tap/dsp/` ✅ |
| RatioTap | `tap::ratio` | `tap::ratio` | `tap/ratio/` ✅ |
| AmbiTap | `tap::ambi` | `tap::ambi` | `ambitap/` |
| SampleRateTap | `tap::samplerate` | `tap::samplerate` | `srt/` |
| MuTap | `tap::mu` | `tap::mu` | `mutap/` |
| TapTools | `tap::tools` | `tap::tools` | `taptools/` |
| OscTap | `tap::osc` | `tap::osc` | `osctap/` |
| PythonTap | `tap::python` | `tap::python` | `tap/python/` ✅ |

**Namespaces and CMake aliases are done everywhere.** Every library above
exports its `tap::<library>` alias. Where a repo predates the convention it
*also* keeps its older alias spelling (`AmbiTap::ambitap`, `MuTap::MuTap`,
`SampleRateTap::SampleRateTap`, `TapTools::taptools`, bare `oscpack`,
`tap::python_core`) so existing consumers keep working — the `tap::` form is
additive, and is what new code should use. Note the aliases are build-tree targets: a repo whose install rules
export a config package still exports under its own namespace, so `find_package`
consumers see the older spelling until that is migrated too.

**Header paths still vary**, and deliberately: renaming `include/mutap/x.h` to
`include/tap/mu/x.h` breaks every `#include` in every consumer, so each repo
migrates when it is next touched for other reasons, keeping a forwarding header
during transition. `SampleRateTap` is the odd one out twice over — `srt/` is an
abbreviation that matches neither its repo name nor its `tap::samplerate`
namespace.

This convention is recorded here rather than in the drift-checked `STYLE.md` so
it does not force a re-sync across every repo; promote it into `STYLE.md` (a
tagged release) once the header paths have migrated too and the whole thing can
be enforced.

Repos absent from the table are not libraries: `TapTools-Max`, `AmbiTap-Max`,
`MuTap-Max` and `AmbiTap-Pd` are host packages (Max/MSP or Pure Data), whose C++
is wrapper glue over one of the libraries above rather than a namespace of its
own. `PythonTap` is both: its host-independent core (the embedded CPython layer,
under `core/`) is the `tap::python` library in the table, and its Max external is
glue over that core.

## Known divergences across the family

Written down so they are decided rather than rediscovered. None of these is
drift-checked; each is a deliberate open item with a known fix.

- **CMake option prefixes** — five forms: `TAP_DSP_*`, `TAP_RATIO_*`,
  `AMBITAP_*`, `MUTAP_*`, `SRT_*`, `TAPTOOLS_*`. Cosmetic, and renaming an option
  breaks that repo's own CI invocations and scripts, so nothing here is worth
  churning on its own. The upper-snake-of-the-namespace form (`TAP_DSP_`,
  `TAP_RATIO_`) is the target; adopt it in a repo already being reworked.
- **Install / export rules** — only AmbiTap and TapTools generate install rules
  and a config package. DspTap, MuTap, RatioTap and SampleRateTap generate none.
  This is defensible: all four are consumed as git submodules via
  `add_subdirectory`, so nothing installs them today, and speculative install
  rules are dead CMake that rots. Add them the first time a repo actually needs
  `find_package` support.
- **Test framework** — TapTools uses Catch2 (`SCENARIO`-style, one binary);
  every other library uses GoogleTest (`TYPED_TEST_SUITE` batteries). This is a
  real difference in kind, not an accident, and converting either direction would
  discard working tests. Left as is.
- **GoogleTest version** — AmbiTap pins v1.15.2, the other four v1.14.0. All five
  now fetch by `GIT_REPOSITORY` + commit pin (AmbiTap previously used a release
  *tarball*, the one mechanism a proxied build environment blocks). Unifying the
  version is a separate, deliberate call.
- **C ABI export decoration** — every library ships a `tools/capi` C ABI, and CI
  now compiles it in all of them, but only DspTap's headers carry
  `__declspec(dllexport)`. The others therefore build the C ABI on Linux/macOS
  legs only: an MSVC build would link a DLL exporting nothing, which would pass
  CI without gating anything. Give the ABI an export macro and flip those legs on
  in the same change.
- **C++ standard in host packages** — *resolved.* TapTools-Max, AmbiTap-Max,
  MuTap-Max, AmbiTap-Pd and PythonTap all force C++20 on every external and test
  target (Min otherwise pins C++17), PythonTap with TapTools-Max's
  `BUILDSYSTEM_TARGETS` loop.
- **ctypes bridge module** — four libraries expose their C ABI to the notebooks
  through a bridge (`ambitap_py.py`, `dsptap_py.py`, `ratiotap_py.py`,
  `taptools_py.py`); MuTap and SampleRateTap do not. **Decided: leave both as
  they are.**
  - *MuTap needs no bridge.* Its ctypes boilerplate lives in exactly one place,
    `tools/notebook/build_afc_demo.py` (one `CDLL`, 16 `argtypes`/`restype` lines);
    the other generator has none. That file *generates and executes* its notebook
    and its own docstring says the source lives there rather than in the `.ipynb`,
    so a bridge would relocate code, not deduplicate it.
  - *SampleRateTap has real duplication but closing it costs more than it saves.*
    Three notebooks (`asrc_demo`, `asrc_block_size_study`, `asrc_comparison`) each
    carry the same 19-line loader inline — `_find_dso()`, the `srt_capi` build
    call, `CDLL`, and six `srt_*` signature declarations — so ~57 lines would
    collapse into one module. But the notebooks are committed *executed*, and
    editing their code cells means re-running them: they embed 12 figures between
    them, and `asrc_comparison` measures against **libsamplerate and soxr**, whose
    output is the evidence. Re-executing anywhere but the author's machine would
    replace measured comparative numbers, and re-render every figure, for a
    cosmetic gain. Revisit only when one of those notebooks is being re-executed
    for a substantive reason anyway — then fold the bridge into the same change.

## Adopting the rules in a repo

1. **Sync the configs** into the repo root:
   ```sh
   git clone https://github.com/tap/taphouse
   taphouse/scripts/sync.sh /path/to/your-repo
   ```
   Commit the resulting `.clang-format`, `.clang-tidy`, `STYLE.md`, and
   `.pre-commit-config.yaml`. A repo with a mark also takes its icons: add
   `--icon <Library>` (the mark it uses — `TapTools` for TapTools-Max; the map
   is in [`brand/README.md`](brand/README.md#icons-in-the-repos)), commit the
   icon files it copies, and put the mark in the README's title (the snippet
   is in the same section).

2. **Enable the local hook** — once per clone:
   ```sh
   pipx install pre-commit   # or: pip install pre-commit
   cd /path/to/your-repo && pre-commit install
   ```
   Now `git commit` reformats staged C/C++ with TapHouse's pinned clang-format
   before the commit lands. First run fetches the pinned hook; thereafter it is
   cached and offline. (Claude Code **web** sessions do this automatically via
   the synced SessionStart hook, once it's merged on the repo's default
   branch — no per-clone step there.)

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
         # icon: TapTools   # repos with a mark (from v6): guards the icon files
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

A changed icon travels the same way: regenerate it with
`brand/make_icons.py`, tag, then `sync.sh --icon <Library>` in each repo that
uses it.

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
