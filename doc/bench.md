# Benchmark: many connections

[`bench/echo.atm`](../bench/echo.atm): `N` clients and an echo server in
one program, on the loopback. Each client sends `K` lines and reads each
echo, with `N x K = 20000` round trips in all cases.

```
./atmos-uv bench/echo.atm 1000 20       # with ATMOS_CFLAGS=-O2
```

Time in milliseconds, three runs each, libuv 1.48, Linux, one core:

| N x K | a broadcast per callback | an emit to one task |
|-------|-------------------------:|--------------------:|
| 10 x 2000 | 374, 396, 357 | 196, 171, 173 |
| 100 x 200 | 2084, 2054, 2186 | 312, 207, 213 |
| 1000 x 20 | 7880, 7796, 6533 | 465, 468, 372 |

- **A broadcast per callback** (commit `37e5e29`): each callback of libuv
  emitted `:uv` to the whole program, and each waiting task filtered it
  with a predicate. Every event visited every waiting task, so the time
  grew with the number of connections: 20 times from 10 to 1000.
- **An emit to one task** (`atm_emit_to`, which the compiler gained for
  this): the callback awakes the task that waits for it, and the time is
  almost flat: about 2 times from 10 to 1000, which includes the 1000
  connects.

Not measured: a comparison with libuv in C, with Céu, or with another
runtime.

## 2026-11-20: back to the broadcast

`atm_emit_to` loses an exception that a task raises after the operation it
awaited: the target of the emit (the task inside the operation) ends, its
end awakes the task of the program, which is outside the target, and the
exception of that task never reaches its `catch` (the program hangs or
ends with it). `tst/throw-after.atm` shows it, and the defect was reported
to the compiler with a program of 30 lines and no libuv.

Until it is fixed, `uv.atm` wakes its tasks with a broadcast and a filter
again (correct and slower). The numbers of this version are below; the
numbers above stay as the measure of what the fix will give back.

| N x K | a broadcast per callback (2026-11-20) |
|-------|--------------------------------------:|
| 10 x 2000 | 344, 345, 342 |
| 100 x 200 | 2115, 1953, 1997 |
| 1000 x 20 | 6042, 6621, 6372 |

About 18 times from 10 to 1000, as with the first broadcast.

## 2026-11-20: the emit to one task again

The runtime fixed the defect (`ia-atmos/lang` `7e3b7b5`), and `uv.atm` wakes
with `atm_emit_to` again; `tst/throw-after.atm` passes.

| N x K | an emit to one task (2026-11-20) |
|-------|---------------------------------:|
| 10 x 2000 | 180, 201, 179 |
| 100 x 200 | 253, 233, 227 |
| 1000 x 20 | 465, 655, 467 |

About 2.5 times from 10 to 1000, against 18 with the broadcast.
