# env-uv: the network, files, and timers for Atmos, over libuv

An environment for [Atmos][atmos] as a direct binding to [libuv][libuv]:
the program runs inside the loop of libuv, and its handles and requests
become values and tasks of the language.

- A handle (a connection, a server) is a native value: `pin` gives it the
  life of its block, so that aborting a task closes its connections.
- An operation that waits (connect, accept, read, write) is a task:
  `await uv.tcp.connect("127.0.0.1", 7000)`.
- Time passes with the clock of the loop: `await 1s` needs no timer of
  libuv.

The model is [ceu-libuv][ceu-libuv], the binding for Céu, whose samples
are the tests of this repository.

[atmos]:     https://github.com/ia-atmos/lang
[libuv]:     https://libuv.org
[ceu-libuv]: https://github.com/ceu-lang/ceu-libuv

## Using

The environment is the single file `uv.atm`:

```
include "uv.atm"

loop i in 5 {
    await 1s
    print((i+1) ++ "s elapsed...")
}
```

```
ATMOS_LDFLAGS="-luv" atmos prog.atm
```

It needs the Atmos compiler and libuv with its headers (`libuv1-dev` in
Debian and Ubuntu; developed with libuv 1.48).

## Testing

```
tst/run.sh              # every test against its stored output, with the address sanitizer
tst/run.sh timer-01     # some tests only
```

The tests use no network outside: clients and servers run in one program,
on the loopback.

## State

In progress: see `.claude/plans/261113-env-uv.md`.
Only Linux is tested. libuv also runs on the Mac and on Windows, which is
the reason to choose it, but this environment was not tested there.
