#!/usr/bin/env bash
# Self-check for scripts/tidy.sh: drives the real script with a fake clang-tidy
# and asserts its verdict. TapHouse-only — not synced into consumers and not
# drift-guarded; run by .github/workflows/test.yml and by hand:
#
#   scripts/test-tidy.sh                    # tests ./scripts/tidy.sh
#   scripts/test-tidy.sh path/to/tidy.sh    # tests another copy (e.g. an old one)
#
# The regression it exists for: tidy.sh used to test its captured output with
# `printf '%s\n' "$out" | grep -qE "warning:|error:"` under `set -o pipefail`.
# grep -q exits at its first match; if printf still has more than a pipe
# buffer left to write it dies of SIGPIPE, the pipeline fails, and the `if`
# takes the CLEAN branch — "clang-tidy clean." printed over real warnings.
# Seen 2026-09-24 (synthetic) and 2026-10-02 in MuTap-Max, where ~420 min-api
# header warnings per TU hid six real naming violations. large-warning-first
# below reproduces it (the old script fails that case and no other: a warning
# on the LAST line is found only after printf has finished writing, so the
# pipe never breaks). The fixed script passes every case.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tidy="${1:-$here/scripts/tidy.sh}"
tidy="$(cd "$(dirname "$tidy")" && pwd)/$(basename "$tidy")"
if [ ! -x "$tidy" ]; then
    echo "error: '$tidy' is not an executable script" >&2
    exit 2
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# An existing compile database, so tidy.sh never runs cmake; a fake clang-tidy
# that prints whatever file FAKE_TIDY_OUTPUT names.
mkdir -p "$tmp/build" "$tmp/bin"
echo '[]' >"$tmp/build/compile_commands.json"
cat >"$tmp/bin/clang-tidy" <<'EOF'
#!/usr/bin/env bash
cat "$FAKE_TIDY_OUTPUT"
EOF
chmod +x "$tmp/bin/clang-tidy"

# Fixtures. The large ones must exceed any pipe buffer (64 KiB on Linux and
# macOS) by a wide margin: 100 000 note lines is ~6 MB.
warning="/src/foo.cpp:12:5: warning: invalid case style for variable 'fooBar' [readability-identifier-naming]"
notes() {
    awk -v n="$1" 'BEGIN { for (i = 1; i <= n; i++) print "/deps/min-api/include/c74_min.h:" i ":1: note: expanded from macro" }'
}
{ echo "$warning"; notes 100000; } >"$tmp/large-warning-first"
{ notes 100000; echo "$warning"; } >"$tmp/large-warning-last"
echo "$warning" >"$tmp/small-warning"
: >"$tmp/empty-clean"
notes 100000 >"$tmp/large-clean"
for f in large-warning-first large-warning-last large-clean; do
    bytes="$(wc -c <"$tmp/$f")"
    if [ "$bytes" -lt 204800 ]; then
        echo "error: fixture $f is only $bytes bytes; need >= 200 KiB to exceed the pipe buffer" >&2
        exit 2
    fi
done

echo "== testing $tidy =="
fail=0
# run_case NAME FIXTURE WANT_EXIT WANT_TEXT [WANT_IN_STDOUT]
run_case() {
    local name="$1" fixture="$2" want="$3" text="$4" shown="${5:-}" got=0
    FAKE_TIDY_OUTPUT="$tmp/$fixture" CLANG_TIDY="$tmp/bin/clang-tidy" TIDY_BUILD="$tmp/build" \
        "$tidy" /src/foo.cpp >"$tmp/stdout" 2>"$tmp/stderr" || got=$?
    if [ "$got" -ne "$want" ]; then
        echo "FAIL $name: exit $got, want $want"
        fail=1
    elif ! grep -qF -- "$text" "$tmp/stdout" "$tmp/stderr"; then
        echo "FAIL $name: expected '$text' in the verdict"
        fail=1
    elif [ -n "$shown" ] && ! grep -qF -- "$shown" "$tmp/stdout"; then
        echo "FAIL $name: the diagnostic itself was not reported"
        fail=1
    else
        echo "ok   $name ($(wc -c <"$tmp/$fixture" | tr -d ' ') bytes of clang-tidy output -> exit $got)"
        return 0
    fi
    echo "---- stdout (tail) ----"; tail -n 3 "$tmp/stdout"
    echo "---- stderr (tail) ----"; tail -n 3 "$tmp/stderr"
}

run_case large-warning-first large-warning-first 1 "clang-tidy found violations" "$warning"
run_case large-warning-last  large-warning-last  1 "clang-tidy found violations" "$warning"
run_case small-warning       small-warning       1 "clang-tidy found violations" "$warning"
run_case empty-clean         empty-clean         0 "clang-tidy clean."
run_case large-clean         large-clean         0 "clang-tidy clean."

if [ "$fail" -eq 0 ]; then
    echo "tidy.sh self-test passed."
else
    echo "tidy.sh self-test FAILED." >&2
    exit 1
fi
