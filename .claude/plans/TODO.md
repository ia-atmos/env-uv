# TODO

Everything pending in this session (`env-uv`, repository `ia-atmos/env-uv`):
explicit, unanswered, or unacknowledged. Kept current as the work goes.

The working plan is `.claude/plans/261113-env-uv.md`.

Items are `#N` (standing rule of the author, 2026-11-18): unique in this
session, taken in order, never reused or renumbered; from another session,
`env-uv#N`. The index below is the list of all of them, with their state.

## State

- 2026-11-25: the pause of 2026-11-23 is over (relayed by `atmos`). Done
  since: the guide covers processes, datagrams, signals, and the pair.
  Items waiting: #2, #3, #4 (with `atmos-envs`); later: #7, #10.

## Index

| # | Title | Kind | State |
|---|-------|------|-------|
| #1 | The local remote points to `fsantanna/uv` | decision of the author | won't do: the new address is refused (403); the old one redirects |
| #2 | Gap of `atmos.env`: a primary that waits delays the secondaries | remark, to `atmos-envs` and the author | sent again 2026-11-22 with a general form (an `fd` per env); with `atmos-envs` |
| #3 | Gap of `atmos.env`: the dedicated compiler forces which env is primary | remark, to `atmos-envs` and the author | sent again 2026-11-22 (primary-only wins); with `atmos-envs` |
| #4 | With secondaries, the primary cannot know that nothing can awake the program | remark, to `envs` | open |
| #5 | A factory may not own the handle it gives away (`val s` in `uv.tcp.listen`) | remark, to `atmos-pin` | closed by `atmos-pin#8`: no change |
| #6 | The trace of an error in an awaited task lacks the line of the `await` | defect, to `atmos-lang` | fixed: merged in `lang` `61979ce` (`atmos-lang#13`); `fs-00.out` gains the lines |
| #7 | A test mode by a global in a `test` block of `uv.atm` (`envs` item 58) | work | later |
| #8 | A limit for the buffer of a stream (a line with no end grows forever) | work | done (`b7e5592`) |
| #9 | UDP, processes, pipes, signals, a small HTTP server | work | done (2026-11-20, `39b2e1c`..`7fe8470`) |
| #10 | Not tested: IPv6 (the container has none), the Mac, Windows | remark | open |
| #11 | The numeric options of the build (`ATMOS_FLOAT`, `ATMOS_INTEGER`, `ATMOS_CLOCK`, formerly `ATMOS_REAL`, `ATMOS_INT`, `ATMOS_TIME`) in `uv.atm` | work | done; new C names with a bridge to the old ones; `mtime` in whole seconds by the session, to be confirmed |
| #12 | `atm_emit_to` lost an exception raised after an awaited operation | defect, to `atmos-lang` | fixed in `lang` `7e3b7b5`; `uv.atm` back to `atm_emit_to` |
| #13 | Excerpt, idiomatic: a process ends with the task that holds it (`tst/proc-01.atm:49`) | excerpt of #9 | shown 2026-11-26 |
| #14 | Excerpt, bad: the timeout of a request needs a `var` and a `set` (`exs/http.atm:57`) | excerpt of #9 | fixed in the language (`lang` `80ed120`, `atmos-lang#132`): `val ok, res = watching ...`; applied here |

## #1 The local remote points to `fsantanna/uv`

- The repository was renamed to `ia-atmos/env-uv`; `git push` worked through
  the redirect. 2026-11-22: the author allowed the change, else won't do.
  Tried: a push to `https://github.com/ia-atmos/env-uv` is refused (403),
  since the access of this session to GitHub is scoped to `fsantanna/uv`.
  Won't do: the remote stays the old address, which redirects; harmless
  (only the message "This repository moved" at each push).

## #2, #3, #4 Gaps of `atmos.env`

- From the pilot with `env-iup` (2026-11-17, `d35e69d`..`ecc8b48`), reported
  to `envs` (session_011eECofYWTNPACTtUjHN4p6) and the author. Two other gaps
  were fixed in the runtime (`c12cf52`: quits after the variables; errors of
  a step), and `uv.atm` was simplified (`a4e1531`).
- #2: the network of a pair has up to 10ms of latency (the tick of IUP).
  The general form, sent to `atmos-envs` on 2026-11-22 at the author's
  request: #2a, each env may give a descriptor that becomes readable when
  it has work (a field `fd`; libuv `uv_backend_fd`), which the primary
  adds to its wait; #2b, a thread-safe `wake()` of the primary where there
  are no descriptors; #2c, the short bound of today as the fallback.
  Recommended: #2a with #2c.
- #3: `atmos-uv` includes `uv.atm` first, so a pair needs the plain
  compiler with the primary included first. Sent to `atmos-envs` on
  2026-11-22: #3a, the runtime picks the primary after the main chunk (an
  env that supports only `primary` wins); #3b, `mode.prefer`.
  Recommended: #3a.
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
- Closed by `atmos-pin` on 2026-11-21: on a throw, the `val` of the
  function is the only reference and goes when the block unwinds, so the
  handle closes where a `pin` would close it; the caller owns it. No
  change to the rules.

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
- 2026-11-21: the C names of the rename of `lang` branch `float`
  (`A_CLOCK_US`, `AFloat`), with a bridge in the prelude to the old ones
  (`A_TIME_US`, `AReal`), so that `uv.atm` builds on `lang` main and on
  `float` `e415507`; tested on both, and on `float` with `ATMOS_CLOCK=ms`
  and with the three options. After the merge of `float`: the names of the
  shell variables in `doc/api.md`, and the bridge may go.
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
- Fixed by `atmos-lang` on 2026-11-20 (`7e3b7b5`, its case
  `tst/cases/env-emit-to-02` is my program); `uv.atm` wakes with
  `atm_emit_to` again, and `tst/throw-after.atm` passes.

## #9 UDP, pipes, processes, signals, HTTP

- Done 2026-11-20, each with its test: `uv.udp.*` (`udp-01`), `uv.pipe.*`
  local sockets (`pipe-01`), `uv.proc.*` (`proc-01`), `uv.signal.*` and
  `uv.pid()` (`signal-01`), and `exs/http.atm` (`http-01`, and by hand
  with curl).
- The shapes are mine (by the session, to be confirmed): `uv.udp.recv`
  gives `[data, ip, port]`; `uv.proc.spawn` gives
  `[proc=, stdin=, stdout=, stderr=]` with pipes always; `uv.proc.wait`
  gives `[code=, signal=]`; a running process whose value goes gets
  SIGTERM; signals by number, not by name.

## #13, #14 Excerpts of #9

- #13, idiomatic (`tst/proc-01.atm:49`): a process lives as long as the
  task that holds it; `abort t` closes the handle and sends SIGTERM, with
  no cleanup code.
- #14, bad (`exs/http.atm:57`): `var res = nil ; watching 5s { set res =
  await Request(s) }`. Why: a `watching` that times out evaluates to the
  time that passed (a number), not `nil`, so the natural
  `val res = watching 5s { await Request(s) }` would give a number to the
  write. What would fix it: in the language, a `watching` ended by its
  condition evaluates to `nil` (or to a value given with it); then the
  line is one `val`, and no mutable variable.
- #14 decided by the author on 2026-11-26 (`atmos-lang#132`, `#133`): a
  `watching` gives a boolean before its values, as a `catch`. Applied in
  `exs/http.atm`, `tst/http-01.atm`, and the guide.

## Standing rules of the author

- Reports (2026-11-26, relayed by `atmos`): for each group of changes,
  one pair of Atmos excerpts from that work, one idiomatic and one bad
  (awkward, verbose, a workaround), short, with file and line. No
  screenshots here (no screen). Added the same day: each excerpt has a
  number of this sequence (#N, in the index), and each bad one says why
  it is bad and what would make it better.

- Idioms (2026-11-26, relayed by `atmos`, `atmos#29`): read `ia-atmos/lang`
  `.claude/plans/IDIOMS.md` before writing Atmos. A general rule that
  comes out of a correction or an approval of the author goes to `atmos`
  (source `env-uv#N`, a before and an after). Checked on 2026-11-26: only
  three `await(x)` in tests, fixed.

## Where to send findings

- About `pin`: `atmos-pin` (session_011eECogSDhkVfyt7qme5DLh).
- Coordination, status, and questions for the author: `atmos`
  (session_011eECohhJbc4GMpAj3yyeEo), since 2026-11-24.
- Measurements on the ports, merges into `main` of `ia-atmos/lang`, and
  defects of the compiler: `atmos-lang`
  (session_011eECogKVQ7ZzmWCoMST2wK).
- Environments: `envs` (session_011eECofYWTNPACTtUjHN4p6); the pair:
  `env-iup` (session_011eECoiJLW3LfTrKdHtNFvg).

## Done (before the numbers)

- U0 to U6 of the plan; `atmos.env` with `env-iup` as the pilot; the two
  migrations of `pin`; events as bare tags; errors as `:error.<NAME>`.
