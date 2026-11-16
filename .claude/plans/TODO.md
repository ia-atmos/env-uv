# TODO

Everything pending in this session (`ia-atmos/env-uv`): explicit, unanswered,
or unacknowledged. Kept current as the work goes.

The working plan is `.claude/plans/261113-env-uv.md`.

## A. Decisions waiting for the author

- The local remote still points to `fsantanna/uv` (it redirects): the
  session's permission mode refused the change to `ia-atmos/env-uv`.
- The events are `:read [h=s]`, `:accept [h=srv]`, `:done [h=r]`, as he
  asked on 2026-11-16 ("como no iup"). They still go to the one task
  that waits (`atm_emit_to`), and the program awaits the operations, not
  the events. Should they be broadcasts, so that a program may write
  `await :read [h=s]` itself? The broadcast was 20 times slower with
  1000 connections. The field `h` alone costs about 1.7 times in
  `bench/echo.atm` (a table per event and per await).

## B. Work known and not done

- U6 (the composition with `env-iup`, decided by the author on
  2026-11-16): done for the pair. `uv.atm` has a hosted mode
  (`UVA_NO_MAIN`, `uva_poll`, `uva_close`), `iup.atm` polls it at each
  tick through weak symbols, and `tst/pair/iup-echo.atm` runs the two
  under Xvfb. Open: the latency is the tick of IUP (10ms); the general
  answer (a registry of pollers in the runtime, for any pair) is to ask
  the compiler session and the author; a dedicated compiler for the
  pair; a section in `doc/guide.md`.
- Later: UDP, processes, pipes, signals, a small HTTP server.
- Not tested: IPv6 (the container has none), the Mac, Windows.
- A limit for the buffer of a stream (a line with no end grows forever).
- The trace of an error raised in an awaited task does not show the line
  of the `await` (sent to the compiler session, which put it to the
  author).

## C. Reported and not acknowledged

- (none: findings 1 and 2 were fixed in `ia-atmos/lang`)

## D. Older items

- (none)
