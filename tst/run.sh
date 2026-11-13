#!/bin/sh
# Runs the tests: each tst/<name>.atm against its stored output
# tst/<name>.out, with the address sanitizer.
#
#   tst/run.sh              all tests
#   tst/run.sh tcp-01       some tests only
#   tst/run.sh -u tcp-01    stores the output of the tests
#   ASAN=0 tst/run.sh       with no sanitizer
#
# Needs the Atmos compiler: ATMOS=<path to the binary> (default: `atmos`
# in ../lang, or in the PATH).

cd "$(dirname "$0")/.."
if [ -z "$ATMOS" ]; then
    if [ -x ../lang/atmos ]; then ATMOS=../lang/atmos; else ATMOS=atmos; fi
fi
OUT=build/tst
mkdir -p "$OUT"
FAIL=0
UPDATE=
[ "$1" = "-u" ] && { UPDATE=1; shift; }
[ "${ASAN:-1}" = "1" ] && export ATMOS_ASAN=1
export ATMOS_LDFLAGS="-luv"

TESTS=${*:-$(ls tst/*.atm | xargs -n1 basename | sed 's/\.atm$//')}
for t in $TESTS; do
    if ! "$ATMOS" -o "$OUT/$t" "tst/$t.atm" 2> "$OUT/$t.err"; then
        echo "FAIL $t (build)"; cat "$OUT/$t.err"; FAIL=1; continue
    fi
    (cd tst && timeout 60 "../$OUT/$t") > "$OUT/$t.out" 2>&1
    echo "exit $?" >> "$OUT/$t.out"
    if [ -n "$UPDATE" ]; then
        cp "$OUT/$t.out" "tst/$t.out"; echo "new  $t"
    elif diff -u "tst/$t.out" "$OUT/$t.out"; then
        echo "ok   $t"
    else
        echo "FAIL $t"; FAIL=1
    fi
done
exit $FAIL
