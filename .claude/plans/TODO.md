# TODO

Everything pending in this session (`ia-atmos/env-uv`): explicit, unanswered,
or unacknowledged. Kept current as the work goes.

The working plan is `.claude/plans/261113-env-uv.md`.

## A. Decisions waiting for the author

- The local remote still points to `fsantanna/uv` (it redirects): the
  session's permission mode refused the change to `ia-atmos/env-uv`.

## B. Work known and not done

- `atmos.env`: done (2026-11-17, `d35e69d`..`ecc8b48`), with `env-iup` as the
  pilot; the pair passes with no weak symbols. Reported to `envs` and
  the author: four gaps (quits before `atm_quit`, a waiting primary
  delays the secondaries, the dedicated compiler forces the order, errors
  from callbacks). Later (item 58): a test mode by a global set in a
  `test` block of `uv.atm`.
- U6 (the composition with `env-iup`): done with `atmos.env`; the
  latency of the network is the tick of IUP (10ms).
- Later: UDP, processes, pipes, signals, a small HTTP server.
- Not tested: IPv6 (the container has none), the Mac, Windows.
- A limit for the buffer of a stream (a line with no end grows forever).
- The trace of an error raised in an awaited task does not show the line
  of the `await` (sent to the session `atmos-lang`, which put it to the
  author).

## C. Reported and not acknowledged

- (none: findings 1 and 2 were fixed in `ia-atmos/lang`)

## D. Older items

- (none)
