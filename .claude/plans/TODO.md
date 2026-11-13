# TODO

Everything pending in this session (`ia-atmos/env-uv`): explicit, unanswered,
or unacknowledged. Kept current as the work goes.

The working plan is `.claude/plans/261113-env-uv.md`.

## A. Decisions waiting for the author

- Permission to build the compiler in this container (`make` in the clone
  of `ia-atmos/lang`): the session's permission mode refused it.
- Permission to install `libuv1-dev` (the runtime library `libuv1t64`
  1.48.0 is present; the headers are not).
- (confirm) Who owns the loop: the environment defines `main` and runs the
  loop of libuv, and also offers one step of the loop as a function.
  U0 depends on it.
- (confirm) The order of the features: timers; TCP; streams; names; files.
- (confirm) The samples of `ceu-libuv` as the tests and as the comparison
  with Céu.
- The local remote still points to `fsantanna/uv` (it redirects): the
  session's permission mode refused the change to `ia-atmos/env-uv`.

## B. Work known and not done

- U0: readme, the loop with timers only, the runner of tests.
- U1 to U6: see the plan.
- Talk to the session `iup` (`ia-atmos/env-iup`) about two loops in one
  program, when the loop is in place.

## C. Reported and not acknowledged

- (none)

## D. Older items

- (none)
