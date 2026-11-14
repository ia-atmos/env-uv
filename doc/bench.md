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
