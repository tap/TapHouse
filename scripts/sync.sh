#!/usr/bin/env bash
# Copy the canonical Tap House Rules configs into a target repo root.
#
# Usage:  scripts/sync.sh [TARGET_DIR]      (default: current directory)
#
# Run this from a TapHouse checkout. Commit the updated files in TARGET_DIR.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${1:-.}"

if [ ! -d "$target" ]; then
    echo "error: target directory '$target' does not exist" >&2
    exit 1
fi

for f in .clang-format .clang-tidy STYLE.md .pre-commit-config.yaml; do
    cp "$here/$f" "$target/$f"
    echo "synced $f -> $target/$f"
done

# scripts/tidy.sh — the local mirror of the CI clang-tidy gate. Distributed to
# any C++ repo that runs the clang-tidy gate; harmless to carry elsewhere. It is
# drift-guarded only where present (see .github/workflows/drift-check.yml).
mkdir -p "$target/scripts"
cp "$here/scripts/tidy.sh" "$target/scripts/tidy.sh"
chmod +x "$target/scripts/tidy.sh"
echo "synced scripts/tidy.sh -> $target/scripts/tidy.sh"

# Claude Code web SessionStart hook — initializes submodules and installs the
# pinned pre-commit hook in fresh web-session containers, so the clang-format
# gate can never fail on code a local clone would have formatted at commit
# time. The hook script is canonical (drift-guarded where present); the
# .claude/settings.json registration is created only if missing, because repos
# may legitimately extend their settings with repo-specific hooks.
mkdir -p "$target/.claude/hooks"
cp "$here/.claude/hooks/session-start.sh" "$target/.claude/hooks/session-start.sh"
chmod +x "$target/.claude/hooks/session-start.sh"
echo "synced .claude/hooks/session-start.sh -> $target/.claude/hooks/session-start.sh"
if [ ! -f "$target/.claude/settings.json" ]; then
    cp "$here/.claude/settings.json" "$target/.claude/settings.json"
    echo "created $target/.claude/settings.json (registers the hook; repo-specific settings merge there)"
fi

# Pull-request template — the family's shared review prompts (verification
# provenance, contract changes, submodule pin flow). Created only if missing and
# deliberately NOT drift-guarded: it is prose for humans, not a machine-enforced
# config, and repos legitimately tailor it (the Max/Pd packages, OscTap's
# documented exceptions). Guarding it would fail CI on a repo that improved its
# own copy.
mkdir -p "$target/.github"
if [ ! -f "$target/.github/pull_request_template.md" ]; then
    cp "$here/.github/pull_request_template.md" "$target/.github/pull_request_template.md"
    echo "created $target/.github/pull_request_template.md (tailor freely; not drift-guarded)"
fi

echo "Done. Review and commit the updated files in: $target"
