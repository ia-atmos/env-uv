# TODO

Everything pending in this session (`env-uv`, repository `ia-atmos/env-uv`):
explicit, unanswered, or unacknowledged. Kept current as the work goes.

The working plan is `.claude/plans/261113-env-uv.md`.

Items are `#N` (standing rule of the author, 2026-11-18): unique in this
session, taken in order, never reused or renumbered; from another session,
`env-uv#N`. The index below is the list of all of them, with their state.

## Index

| # | Title | Kind | State |
|---|-------|------|-------|
| #1 | The local remote points to `fsantanna/uv` | decision of the author | open |
| #2 | Gap of `atmos.env`: a primary that waits delays the secondaries | remark, to `envs` and the author | open, with the author |
| #3 | Gap of `atmos.env`: the dedicated compiler forces which env is primary | remark, to `envs` and the author | open, with the author |
| #4 | With secondaries, the primary cannot know that nothing can awake the program | remark, to `envs` | open |
| #5 | A factory may not own the handle it gives away (`val s` in `uv.tcp.listen`) | remark, to `atmos-pin` | kept there as `atmos-pin#8` |
| #6 | The trace of an error in an awaited task lacks the line of the `await` | defect, to `atmos-lang` | open, with the author |
| #7 | A test mode by a global in a `test` block of `uv.atm` (`envs` item 58) | work | later |
| #8 | A limit for the buffer of a stream (a line with no end grows forever) | work | done (`b7e5592`) |
| #9 | UDP, processes, pipes, signals, a small HTTP server | work | later |
| #10 | Not tested: IPv6 (the container has none), the Mac, Windows | remark | open |
| #11 | The numeric options of the build (`ATMOS_REAL`, `ATMOS_INT`, `ATMOS_TIME`) in `uv.atm` | work | done; `mtime` in whole seconds by the session, to be confirmed |
| #12 | `atm_emit_to` loses an exception raised after an awaited operation; back to the broadcast | defect, to `atmos-lang`; workaround by the session, to be confirmed | open |

## #1 The local remote points to `fsantanna/uv`

- The repository was renamed to `ia-atmos/env-uv`; `git push` works through
  the redirect. The session's permission mode refused to change the
  remote: it needs the author's permission.

## #2, #3, #4 Gaps of `atmos.env`

- From the pilot with `env-iup` (2026-11-17, `d35e69d`..`ecc8b48`), reported
  to `envs` (session_011eECofYWTNPACTtUjHN4p6) and the author. Two other gaps
  were fixed in the runtime (`c12cf52`: quits after the variables; errors of
  a step), and `uv.atm` was simplified (`a4e1531`).
- #2: the network of a pair has up to 10ms of latency (the tick of IUP).
  #2a: a secondary gives the primary a descriptor to wake it
  (`uv_backend_fd`).
- #3: `atmos-uv` includes `uv.atm` first, so a pair needs the plain
  compiler with the primary included first.
- #4: "true ends the program" is only safe for a primary alone; `uv.atm`
  no longer ends the program when it has secondaries (`env-primary.atm`).

## #5 A factory may not own the handle it gives away

- `uv_tcp_listen`, `uv_tcp_accept`, `uv_tcp_connect_ip` declare the handle
  `val`: a pin given away by its block is an error. If the function throws
  before it returns, the handle closes by its last reference, not by the
  block. Passed to `atmos-pin` (session_011eECogSDhkVfyt7qme5DLh), which
  keeps it as `atmos-pin#8`. The author declared the rules of `pin` stable
  on 2026-11-19 (`atmos-pin#9`, `lang` `8361f88`): a later change that
  breaks programs will say what migrates.

## #6 The trace of an error in an awaited task

- `uv.atm:? (call)`, `uv.atm:? (throw)`, not the line of the program that
  awaits the operation. Sent to `atmos-lang`, which put it to the author.

## #11 The numeric options of the build

- Done 2026-11-20: the time is given in the unit of the build
  (`A_TIME_US`), the next timer is read in it, `uv.now()` counts from the
  start of the loop (so it fits 32 bits for 24 days), and sizes and
  positions of files are `a_numi` (a real over 2GB with `ATMOS_INT=32`).
  The 36 tests pass in the default build, under each option, and under
  the three together.
- By the session, to be confirmed: `mtime` is in whole seconds in every
  build (a real of 32 bits cannot hold the seconds since 1970 with a
  fraction).

## #8 A limit for a line

- Done 2026-11-20 (`b7e5592`, test `tst/line-max.atm`): `uv.stream.line`
  and `uv.fs.line` take a maximum (64K by default); a longer line is
  `:error.E2BIG` ("line too long"), and its bytes stay in the buffer.
  The limit and its default are mine: the author may change them.

## #12 `atm_emit_to` loses an exception raised after an operation

- Found doing #8 (2026-11-20): a task that awaits an operation and throws
  when it resumes loses its exception (the program hangs or ends with
  it), because the target of `atm_emit_to` (the task inside the
  operation) ends and its end awakes the task outside the target.
  Present since `atm_emit_to` was adopted (2026-11-14); no test caught it.
- Reported to `atmos-lang` with a program of 30 lines and no libuv.
- By the session, to be confirmed: `uv.atm` wakes with a broadcast and a
  filter again (`b7e5592`); `tst/throw-after.atm` guards it. The cost:
  1000 connections are about 18 times slower than 10 (`doc/bench.md`).
  When the runtime is fixed, go back to `atm_emit_to`.

## Where to send findings

- About `pin`: `atmos-pin` (session_011eECogSDhkVfyt7qme5DLh).
- Anything else in the compiler: `atmos-lang`
  (session_011eECogKVQ7ZzmWCoMST2wK).
- Environments: `envs` (session_011eECofYWTNPACTtUjHN4p6); the pair:
  `env-iup` (session_011eECoiJLW3LfTrKdHtNFvg).

## Done (before the numbers)

- U0 to U6 of the plan; `atmos.env` with `env-iup` as the pilot; the two
  migrations of `pin`; events as bare tags; errors as `:error.<NAME>`.
