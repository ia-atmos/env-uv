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

- U5: `doc/api.md`, `doc/guide.md`, the comparison with Céu; the
  documents and the readme use `atmos-uv`.
- U6: to decide with the author: UDP, processes, an application, a GUI.
- A benchmark of many connections, before and after `atm_emit_to`
  (promised to the compiler session).
- Talk to the session `iup` (`ia-atmos/env-iup`) about two loops in one
  program: `uva_step` is ready for it.
- To the compiler session, not sent yet: the trace of an error raised in
  an awaited task does not show the line of the `await`; an uncaught
  table shows as `table: 0x...`.

## C. Reported and not acknowledged

- (none: findings 1 and 2 were fixed in `ia-atmos/lang`)

## D. Older items

- (none)
