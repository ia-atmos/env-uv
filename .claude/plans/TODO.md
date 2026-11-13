# TODO

Everything pending in this session (`ia-atmos/env-uv`): explicit, unanswered,
or unacknowledged. Kept current as the work goes.

The working plan is `.claude/plans/261113-env-uv.md`.

## A. Decisions waiting for the author

- The local remote still points to `fsantanna/uv` (it redirects): the
  session's permission mode refused the change to `ia-atmos/env-uv`.
- Names of the events and tags across environments (the plan leaves it
  open): here, errors are `:uv.error.<NAME>`, and the only event is the
  internal `:uv`.

## B. Work known and not done

- U4: files, and the twelve file samples of `ceu-libuv`.
- U5: `doc/api.md`, `doc/guide.md`, the comparison with Céu.
- U6: to decide with the author: UDP, processes, an application, a GUI.
- A benchmark of many connections, to measure the cost of the broadcast
  per callback (promised to the compiler session).
- Talk to the session `iup` (`ia-atmos/env-iup`) about two loops in one
  program: `uva_step` is ready for it.

## C. Reported and not acknowledged

- To the compiler session: finding 1, `pin b = await T()` fails with
  "invalid pin : shared value".
- To the compiler session: finding 2, `a_emit(task, evt)` from a driver
  returns the exit of the task instead of delivering it to who awaits.

## D. Older items

- (none)
