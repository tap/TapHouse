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

echo "Done. Review and commit the updated files in: $target"
