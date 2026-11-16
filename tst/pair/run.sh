#!/bin/sh
# Runs the tests of the pair env-iup + env-uv, with no screen: a program
# with the two includes, built with `-DUVA_NO_MAIN`, under a script of
# actions of env-iup (its test mode).
#
#   tst/pair/run.sh [-u]
#
# Needs a checkout of ia-atmos/env-iup beside this repository, with the
# binaries of IUP in it (`./get-iup.sh` there), and `xvfb-run`. Without
# them the tests are skipped.

cd "$(dirname "$0")/../.."
LANG_DIR=${LANG:-../lang}
IUP=$(cd ../env-iup 2>/dev/null && pwd)/iup
if [ ! -f "$IUP/libiup.so" ] || ! command -v xvfb-run > /dev/null; then
    echo "skip pair (no ../env-iup/iup, or no xvfb-run)"
    exit 0
fi
OUT=build/pair
mkdir -p "$OUT"
FAIL=0
[ "${ASAN:-0}" = "1" ] && export ATMOS_ASAN=1
for f in tst/pair/*.atm; do
    t=$(basename "$f" .atm)
    script=$(grep -v '^#' "tst/pair/$t.script" | grep -v '^$' | paste -sd";" -)
    if ! ATMOS_CFLAGS="-DUVA_NO_MAIN -I$IUP/include" \
         ATMOS_LDFLAGS="-L$IUP -liup -Wl,-rpath,$IUP -luv" \
         "$LANG_DIR/atmos" -o "$OUT/$t" "$f" 2> "$OUT/$t.err"; then
        echo "FAIL pair/$t (build)"; cat "$OUT/$t.err"; FAIL=1; continue
    fi
    GTK_THEME=Adwaita LSAN_OPTIONS=exitcode=0 IUP_ATM_SCRIPT="$script" \
        timeout 60 xvfb-run -a -s "-screen 0 640x480x24" \
        sh -c '"$0" > "$1" 2> "$2"' "$OUT/$t" "$OUT/$t.out" "$OUT/$t.log"
    echo "exit $?" >> "$OUT/$t.out"
    if [ "$1" = "-u" ]; then
        cp "$OUT/$t.out" "tst/pair/$t.out"; echo "new  pair/$t"
    elif diff -u "tst/pair/$t.out" "$OUT/$t.out"; then
        echo "ok   pair/$t"
    else
        echo "FAIL pair/$t"; FAIL=1
    fi
done
exit $FAIL
