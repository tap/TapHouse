# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**TapHouse** — the single source of truth for the Tap family's shared style and setup files.
Nothing here is consumed at build time; the files are *distributed as copies* into each consumer
repo's root by `scripts/sync.sh`, and consumer CI runs the reusable
`.github/workflows/drift-check.yml` against a pinned tag to guarantee the copies never silently
diverge. `README.md` is the authoritative description of the mechanism; read it before changing
anything.

## The rules that keep this working

- **Never hand-edit a synced copy in a consumer repo.** Change the canonical file *here*, tag,
  then re-run `scripts/sync.sh` into each consumer. A hand-edited consumer copy fails that repo's
  drift job — that is the mechanism working, not a nuisance.
- **Adding a file to the canonical set touches three places:** the file itself, the copy step in
  `scripts/sync.sh`, and (if it should be guarded) a comparison in `drift-check.yml`. Files that
  not every consumer carries — `scripts/tidy.sh`, `.claude/hooks/session-start.sh` — are guarded
  *conditionally* (only when present; the hook additionally only when the pinned TapHouse ref
  carries it, so older pins don't break). `.claude/settings.json` is deliberately unguarded and
  synced only-if-missing: repos may extend their settings with repo-specific hooks.
- **Two version knobs, both living here** (see README "Updating the rules"): the TapHouse tag
  (consumers pin it in their `style.yml` `ref:`) and the clang-format version (the mirror `rev:`
  inside `.pre-commit-config.yaml`). Tagging is a deliberate release act — bump consumer `ref:`s
  in the same sweep as the re-sync, and don't move existing tags.
- **Consumer rollout order matters:** merge the TapHouse change first, then sync + commit in
  consumers. The conditional guards make the in-between state safe, but a guarded unconditional
  file (the core four) must exist at the pinned ref before consumers reference it.

## Conventions recorded here but not yet drift-enforced

The family C++ namespace convention lives in README.md (one `tap::<library>` sub-namespace per
repo) rather than in the drift-checked `STYLE.md`, so recording it didn't force a family-wide
re-sync. Promote such conventions into `STYLE.md` (a tagged release) only once every consumer
complies.
