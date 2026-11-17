# TODO

Everything pending in this session (`ia-atmos/env-uv`): explicit, unanswered,
or unacknowledged. Kept current as the work goes.

The working plan is `.claude/plans/261113-env-uv.md`.

## A. Decisions waiting for the author

- The local remote still points to `fsantanna/uv` (it redirects): the
  session's permission mode refused the change to `ia-atmos/env-uv`.

## B. Work known and not done

- Waiting for `atmos.env` in `main` of `ia-atmos/lang` (decision of the
  author on 2026-11-17, relayed by the session `envs`,
  session_011eECofYWTNPACTtUjHN4p6; draft: `.claude/plans/261117-envs-atmos.md`
  of `lang`). Then: `uv.atm` registers itself with
  `atmos.env [step=, quit=, mode=[primary=true, secondary=true]]`
  (primary: `uv_run` ONCE, sleeps, emits the time; secondary: NOWAIT, no
  time); its `main`, `UVA_NO_MAIN`, `uva_poll`, `uva_close` go; keep
  `atm_emit_to` in the callbacks; redo the pair (`include "iup.atm"`
  first, no weak symbols) with the session `iup`; say whether the shape
  is general; report to `envs` and to the author. Later (item 58): a test
  mode by a global set in a `test` block of `uv.atm`.
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
