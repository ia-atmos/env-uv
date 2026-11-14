# TODO

Everything pending in this session (`ia-atmos/env-uv`): explicit, unanswered,
or unacknowledged. Kept current as the work goes.

The working plan is `.claude/plans/261113-env-uv.md`.

## A. Decisions waiting for the author

- The local remote still points to `fsantanna/uv` (it redirects): the
  session's permission mode refused the change to `ia-atmos/env-uv`.
- The events have no prefix, as decided for all environments (`:read`,
  `:accept`, `:done`), and are internal: each goes to one task. The
  errors are still `:uv.error.<NAME>`: keep the prefix in an exception?
- The events have no field `h` (the handle): they reach only the task
  that waits. Is that fine, or should the program see `:read [h=s]`?

## B. Work known and not done

- U6: to decide with the author: UDP, processes, pipes, signals, an
  application (a small HTTP server), the composition with a GUI.
- Talk to the session `iup` (`ia-atmos/env-iup`) about two loops in one
  program: `uva_step` is ready for it, and not tested with another loop.
- Not tested: IPv6 (the container has none), the Mac, Windows.
- A limit for the buffer of a stream (a line with no end grows forever).
- The trace of an error raised in an awaited task does not show the line
  of the `await` (sent to the compiler session, which put it to the
  author).

## C. Reported and not acknowledged

- (none: findings 1 and 2 were fixed in `ia-atmos/lang`)

## D. Older items

- (none)
