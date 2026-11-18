# API: env-uv

The binding is the file [`uv.atm`](../uv.atm), over libuv.
A program runs with `atmos-uv`, the [Atmos](https://github.com/ia-atmos/lang)
compiler dedicated to this environment, which `make` builds:

```
$ ./atmos-uv prog.atm
```

The plain compiler also works, with `include "uv.atm"` in the program and
`ATMOS_LDFLAGS="-luv"`.

Everything lives in the single table `uv`.

- [The loop](#the-loop)
- [Values](#values)
- [Waiting](#waiting)
- [Errors](#errors)
- [Streams](#streams)
- [TCP](#tcp)
- [Names](#names)
- [Files](#files)
- [Other](#other)
- [Modes](#modes)

## The loop

The program runs inside the loop of libuv:

- Time passes with the clock of the loop: `await 1s`, `watching 500ms`, and
  `loop on :clock` work as in any Atmos program, with no timer of libuv.
- The program terminates when its main chunk terminates, or when nothing
  can awake it: no timer of the program, and no active handle or request
  of libuv. A connection that nobody reads is not active; a server that
  listens is.
- At the end, the main chunk is aborted, the handles close, and the loop
  runs until the closes are done.

## Values

A **handle** is a [native value](https://github.com/ia-atmos/lang/blob/main/doc/manual.md#native):

| Value | Created by | `type` |
|-------|------------|--------|
| a stream (a TCP connection, or a TCP server) | `uv.tcp.connect`, `uv.tcp.accept`, `uv.tcp.listen` | `native` |
| a file | `uv.fs.open` | `native` |

A handle closes exactly once: when its `pin` block terminates or aborts,
when its last reference goes away, or with `uv.close(h)`.

```
do {
    pin c = await uv.tcp.connect("127.0.0.1", 7000)
    ...
}                           ;; the connection closes here
```

A handle is born unpinned, and the program gives it an owner: a `pin`
declaration, or a task with a `pin` parameter. A `val` also works, and
the handle then closes with its last reference. A pinned handle cannot
leave its block, such as into a task of a pool that lives outside: a
connection for such a task goes straight from the accept to the task
(see [`uv.tcp.accept`](#tcp)).

An operation on a closed handle raises `invalid stream : closed` or
`invalid file : closed`.

## Waiting

An operation that waits is a **task**, to be awaited:

```
val line = await uv.stream.line(c)
```

Since `await T(...)` evaluates to the result of the task and to the task
itself, enclose it in parentheses to keep only the result:
`print((await uv.stream.line(c)))`.

Aborting the task that awaits aborts the operation:

- a connect, an accept, or a read in course stops, and the stream is free
  for another operation;
- a write or a request on a file that libuv already started may still
  complete, but nobody waits for it;
- a handle that the aborted task holds closes.

```
watching 5s {
    val line = await uv.stream.line(c)      ;; gives up after 5s
    ...
}
```

Only one task at a time reads a stream, accepts from a server, or reads a
file: another one raises `invalid stream : busy` or `invalid file : busy`.

## Errors

An error of libuv is a throw of a table tagged with its name:

```
:error.ECONNREFUSED [name="ECONNREFUSED", msg="connection refused"]
```

```
val ok, e = catch :error {               ;; any error of libuv
    pin c = await uv.tcp.connect("127.0.0.1", 7000)
    ...
}
if !ok {
    print(e.name, e.msg)
}
```

`catch :error.ECONNREFUSED {...}` catches a single error.
The names are those of libuv with no `UV_`: `EOF`, `ENOENT`, `EADDRINUSE`,
`ECONNRESET`, `EAI_NONAME`, and so on.

The end of a stream or of a file is not an error: a read evaluates to `nil`.

An invalid argument (not a handle, not a string) is an error of the
program, with a message as its value: `invalid stream`,
`invalid write : expected string`.

## Streams

| Operation | Result |
|-----------|--------|
| `await uv.stream.read(s)` | the bytes that arrive, as a string, as many as there are |
| `await uv.stream.read(s, n)` | exactly `n` bytes |
| `await uv.stream.line(s)` | a line, with no `"\n"` |
| `await uv.stream.write(s, str)` | writes all bytes of the string |
| `await uv.stream.shutdown(s)` | ends the writes, after the pending ones: the other side reads the end of the stream, and this side may still read |

At the end of the stream, a read evaluates to what is left, if any (fewer
than `n` bytes, or a last line with no `"\n"`), and then to `nil`.

A stream keeps the bytes that arrived and were not consumed, so the three
reads may be mixed. Bytes only arrive while a task reads: with no reader,
they wait in the system, and the other side eventually stops writing.

Strings are sequences of bytes: they may hold any value, including zeros.

## TCP

| Operation | Result |
|-----------|--------|
| `uv.tcp.listen(ip, port, [backlog])` | a server, bound to the address and listening. Port `0` is any free port. |
| `await uv.tcp.accept(srv)` | the next connection to the server, as a stream |
| `await uv.tcp.serve(srv, T, ...)` | spawns `T(s, ...)` for each connection `s`, in a pool. Never terminates. An error of libuv in a `T` terminates only that task. |
| `await uv.tcp.connect(host, port)` | a connection, as a stream. A name is resolved, and its addresses are tried in order. |
| `uv.tcp.addr(s)` | the ip and the port of the stream, as two values |
| `uv.tcp.peer(s)` | the ip and the port of the other side |

Addresses are of IPv4 (`"127.0.0.1"`) or IPv6 (`"::1"`). IPv6 was not
tested: the machine of the tests has none.

A server with a task for each connection:

```
task Client (s) {
    loop {
        val line = await uv.stream.line(s)
        until line == nil
        await uv.stream.write(s, line ++ "\n")
    }
}

pin srv = uv.tcp.listen("0.0.0.0", 7000)
pin cs  = tasks()
loop {
    spawn @cs Client(await uv.tcp.accept(srv))
}
```

The connection belongs to its task: it closes when the task terminates or
is aborted.
`await uv.tcp.serve(srv, Client)` is the same loop.

## Names

| Operation | Result |
|-----------|--------|
| `await uv.dns.lookup(name)` | the addresses of the name, as a vector of strings |

## Files

| Operation | Result |
|-----------|--------|
| `await uv.fs.open(path, [mode], [perm])` | a file. The mode is `"r"` (default), `"w"` (create and truncate), or `"a"` (create and append), with an optional `"+"` to read and write, as `fopen`. The permissions of a new file default to `0644`. |
| `await uv.fs.read(f)` | the next bytes, as a string (at most 64K) |
| `await uv.fs.read(f, n)` | exactly `n` bytes |
| `await uv.fs.line(f)` | a line, with no `"\n"` |
| `await uv.fs.write(f, str)` | writes all bytes of the string, and evaluates to their number |
| `uv.fs.seek(f, pos)` | sets the position of the next read or write |
| `uv.fs.tell(f)` | the position of the next read or write |
| `await uv.fs.stat(f)` | `[size=, mode=, mtime=, file=, dir=]` of an open file, or of a path |
| `await uv.fs.unlink(path)` | removes a file |

A file has one position, which reads and writes advance. A file open with
`"a"` always writes at its end.

At the end of the file, a read evaluates to what is left, if any, and then
to `nil`. A later read tries again, since a file may grow.

The operations run in the threads of libuv and do not block the program:
other tasks execute while a file is read.

## Other

| Operation | Result |
|-----------|--------|
| `uv.now()` | the time of the loop, in milliseconds |
| `uv.close(h)` | closes a handle now |

## Modes

`uv.atm` registers itself with `atmos.env` (manual of Atmos,
"Environments"), and supports both modes:

- **Primary**, when it is the first environment registered, or the only
  one (always, with `atmos-uv`): each step runs the loop of libuv until
  input or the next timer, and gives the time of the loop to the program.
  Alone, it ends the program when nothing can awake it: no timer, and no
  active handle or request of libuv. With secondaries, it waits 10ms at
  most per step, so that they run, and only the main chunk ends the
  program.
- **Secondary**, when another environment came first, such as a GUI: each
  step only delivers what libuv has ready, with no wait, and the primary
  gives the time. `uv.now()` is still the clock of libuv.

A program with two environments includes the primary first, and is built
with the plain compiler and the flags of both libraries, since `atmos-uv`
would include `uv.atm` first:

```
include "iup.atm"
include "uv.atm"
```

The tests `tst/env-secondary.atm` and `tst/env-primary.atm` have the other
environment written in the test, and `tst/pair/iup-echo.atm` runs under
`env-iup`.

The callbacks of libuv emit `:read`, `:accept`, and `:done`, each to the
one task that waits for it, inside an operation (`atm_emit_to`): a
program awaits the operations, and never sees these events.

The names of C in `uv.atm` have the prefix `uva_` or `UVA_`.
`UVA_LOOP` is the loop (`uv_loop_t*`), for native literals of the program
that call libuv directly.

Not in this environment: UDP, pipes, processes, signals, and the threads
of libuv.
