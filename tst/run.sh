#!/bin/sh
# Runs the tests: each tst/<name>.atm against its stored output
# tst/<name>.out, with the address sanitizer.
#
#   tst/run.sh              all tests
#   tst/run.sh tcp-01       some tests only
#   tst/run.sh -u tcp-01    stores the output of the tests
#   ASAN=0 tst/run.sh       with no sanitizer
#
# Uses `atmos-uv`, the compiler dedicated to this environment, which
# `make` builds from the Atmos compiler in ../lang (or LANG=<dir>).

cd "$(dirname "$0")/.."
make -s atmos-uv > /dev/null || exit 1
ATMOS=./atmos-uv
OUT=build/tst
mkdir -p "$OUT"
FAIL=0
UPDATE=
[ "$1" = "-u" ] && { UPDATE=1; shift; }
[ "${ASAN:-1}" = "1" ] && export ATMOS_ASAN=1

# the samples only build: they use fixed ports and long timers
if [ $# = 0 ]; then
    for f in samples/*.atm; do
        ATMOS_ASAN= "$ATMOS" -o "$OUT/sample" "$f" 2> "$OUT/sample.err" ||
            { echo "FAIL $f (build)"; cat "$OUT/sample.err"; FAIL=1; }
    done
    echo "ok   samples (build)"
fi

TESTS=${*:-$(ls tst/*.atm | xargs -n1 basename | sed 's/\.atm$//')}
for t in $TESTS; do
    # a test with another environment first: the plain compiler and the
    # include, since `atmos-uv` would make uv.atm the first one
    case $t in
        env-*) CC1="${LANG:-../lang}/atmos"; L1="-luv" ;;
        *)     CC1="$ATMOS"; L1= ;;
    esac
    if ! ATMOS_LDFLAGS="$L1" "$CC1" -o "$OUT/$t" "tst/$t.atm" 2> "$OUT/$t.err"; then
        echo "FAIL $t (build)"; cat "$OUT/$t.err"; FAIL=1; continue
    fi
    (cd tst && timeout 20 "../$OUT/$t"; echo "exit $?") 2>&1 | sed 's/0x[0-9a-f]*/0x?/g; s|[^ ]*uv.atm:[0-9]*|uv.atm:?|g' > "$OUT/$t.out"
    if [ -n "$UPDATE" ]; then
        cp "$OUT/$t.out" "tst/$t.out"; echo "new  $t"
    elif diff -u "tst/$t.out" "$OUT/$t.out"; then
        echo "ok   $t"
    else
        echo "FAIL $t"; FAIL=1
    fi
done
exit $FAIL
