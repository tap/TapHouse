#!/usr/bin/env bash
# Print the icon files a repo carries, one "SOURCE DEST" pair per line:
# SOURCE relative to the TapHouse root, DEST relative to the repo root.
#
# Usage:  scripts/icon-files.sh LIBRARY [REPO_DIR]   (default: current directory)
#
# LIBRARY is the brand/icons/ folder whose mark the repo uses (TapTools for
# TapTools-Max; see brand/README.md). Which files apply follows from the
# repo's shape:
#
#   every repo             .github/icon-light.svg, .github/icon-dark.svg
#                          (the README header)
#   a book (book/book.toml) book/theme/favicon.svg, book/theme/favicon.png
#   a Max package           icon.png
#   (package-info.json.in)
#
# The one rule for both sides: scripts/sync.sh copies these pairs, and
# .github/workflows/drift-check.yml compares them, so the two cannot disagree.
# Exits non-zero, with a message on stderr, when LIBRARY has no mark or lacks
# a file the repo needs.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
lib="${1:-}"
repo="${2:-.}"

if ! [[ "$lib" =~ ^[A-Za-z]+$ ]]; then
    echo "error: '$lib' is not a library name (brand/icons/<Library>, e.g. TapTools)" >&2
    exit 1
fi

pairs=("brand/icons/$lib/$lib-light.svg .github/icon-light.svg"
       "brand/icons/$lib/$lib-dark.svg .github/icon-dark.svg")
if [ -f "$repo/book/book.toml" ]; then
    pairs+=("brand/icons/$lib/$lib-ground.svg book/theme/favicon.svg"
            "brand/icons/$lib/$lib-32.png book/theme/favicon.png")
fi
if [ -f "$repo/package-info.json.in" ]; then
    pairs+=("brand/icons/$lib/$lib-package.png icon.png")
fi

for pair in "${pairs[@]}"; do
    src="${pair%% *}"
    if [ ! -f "$here/$src" ]; then
        echo "error: $src does not exist; see brand/README.md for the libraries with marks and package icons" >&2
        exit 1
    fi
done
printf '%s\n' "${pairs[@]}"
