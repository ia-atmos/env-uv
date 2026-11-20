# Céu and Atmos over libuv, sample by sample

[ceu-libuv][ceu-libuv] (v0.40, 2018) is the binding of libuv for Céu.
Its samples are ported here, in [`samples/`](../samples), with the same
ports, times, and messages, and again in [`tst/`](../tst), adapted to
run alone as tests (a free port, clients in the program, shorter times).

[ceu-libuv]: https://github.com/ceu-lang/ceu-libuv

## Lines

Lines of code, with no blank lines and no comments, of each sample.

| Sample | What | Céu | Atmos |
|--------|------|----:|------:|
| timer-01 | five timers in sequence | 8 | 4 |
| timer-02 | timers under a `watching` (and a thread in Céu) | 15 | 10 |
| tcp-01 | sequential echo server, raw events | 92 | 15 |
| tcp-02 | parallel echo server, a pool of clients | 31 | 17 |
| tcp-03 | two echo servers | 37 | 20 |
| tcp-04 | two servers, by piece and by line | 65 | 37 |
| tcp-05 | echo client, raw connect | 25 | 8 |
| tcp-06 | echo client, `UV_TCP_Connect` | 15 | (tcp-05) |
| tcp-07 | client and server in one program | 29 | 19 |
| tcp-08 | two servers and four clients, one server stops | 59 | 48 |
| tcp-09 | echo of a big file | 22 | 8 |
| tcp-10 | echo of a big file, by line | 26 | 8 |
| fs-00 | open fails, uncaught | 7 | 3 |
| fs-01 | open fails, caught | 13 | 8 |
| fs-02 | open fails, `UV_FS_Open_Try` | 12 | (fs-01) |
| fs-03 | read in pieces, raw requests | 37 | 6 |
| fs-04 | read in pieces, `UV_FS_Read_N` | 14 | (fs-03) |
| fs-05 | write 20 lines | 23 | 8 |
| fs-06 | size, seek, read the tail | 16 | 8 |
| fs-07 | read by line | 19 | 7 |
| fs-08 | read in small pieces | 13 | 6 |
| fs-09 | write a line | 14 | 7 |
| fs-10 | copy by line, two files open in parallel | 27 | 14 |
| fs-11 | size | 8 | 4 |
| **Total** | 24 samples in Céu, 21 in Atmos | **627** | **265** |

The samples not ported are `async-01` and `threads-01`: threads are out of
this environment.

The bindings themselves:

| | Céu | Atmos |
|--|----:|------:|
| Code in the language | 872 (`uv`, `stream`, `tcp`, `tcp-server`, `fs`) | 190 |
| Code in C | inside the above, in `native` blocks | 870 |

The two are not the same work in different places: ceu-libuv keeps the
buffers and the state of each operation in Céu, and here they are in C,
behind a native value.

The lines are not the point. Three samples differ in Céu only in the
level of the interface they use, and are the same program here, which
is the first thing the comparison shows.

## What each language made explicit

### One level instead of two

ceu-libuv has two levels: the events of libuv as input events of the
program (`UV_STREAM_READ`, `UV_STREAM_CONNECT`, `UV_FS`), and abstractions
over them (`UV_Stream_Read_N`, `UV_TCP_Connect`). The first samples use
the events, to show them: `tcp-01` allocates the client, starts and stops
the read by hand, and filters each event by its handle.

```
// Céu (tcp-01)
var _uv_stream_t&& s;
(s,n_read) = await UV_STREAM_READ until s==(&&client as _uv_stream_t&&);
```

```
;; Atmos
val buf = await uv.stream.read(client)
```

Here there is one level. The callback of libuv awakes the one task that
waits for it, and the program never sees the event. What Céu makes
explicit, and Atmos hides, is that an input may be for somebody else:
`until s==...` is a filter that every reader of every stream executes on
every event. This binding does the same inside its operations (a
broadcast with a filter), and 1000 connections are much slower
than 10 for the same work (about 18 times). An emit to the one task (`atm_emit_to`) made
it almost flat, but it loses an exception raised after an operation, so
it waits for a fix of the runtime (see [bench.md](bench.md)).

### The life of a handle

In Céu, a handle lives inside a `code/await` that never terminates, and
the program holds an alias to its fields while that code runs:

```
// Céu (tcp-06)
var& UV_TCP_Connect c = spawn UV_TCP_Connect("127.0.0.1", DEFAULT_PORT, _);
await c.ok;
... c.stream ...
```

`UV_TCP_Connect` is `-> NEVER`: after it connects, it emits `ok` and
awaits forever, only to keep the stream alive in its block, and its
`finalize` closes the stream when the enclosing block ends.

In Atmos, the connect is a task that terminates with the stream as its
result, and the stream is a value that the program pins to a block:

```
;; Atmos
pin c = await uv.tcp.connect("127.0.0.1", 7000)
```

The two steps of Céu (`spawn`, then `await c.ok`) are one, and the life of
the stream is that of a variable. Céu makes explicit that a resource is
an activity (something is running while the connection exists); Atmos
makes explicit that it is a value, which can be returned, stored, and
passed to a task.

A stream that goes to a task of a pool cannot be pinned where it is
accepted, since it must outlive that block. It goes straight from the
accept to the task, which owns it:

```
spawn @cs Client(await uv.tcp.accept(srv))
```

In Céu, the client task accepts its own connection
(`spawn Client(&server.stream) in cs`), and the stream never crosses a
block. Here it crosses one, as a value with no owner yet, and the rules
of the language say who may take it.

### The end of a stream

In Céu, the end of a stream is an exception (`Exception.Uv`, with
`UV_EOF`), as any other error, and each client catches it:

```
// Céu (tcp-02)
var Exception.Uv? e;
catch e do
    ...
    loop do
        await UV_Stream_Read_N(&client.stream,_);
        await UV_Stream_Write_N(&client.stream,_);
    end
end
_fprintf(_stderr, "[error]: %s\n", e!.message);
```

Here the end is a value: a read evaluates to `nil`, and the loop ends
with `until`.

```
;; Atmos
loop {
    val buf = await uv.stream.read(client)
    until buf == nil
    await uv.stream.write(client, buf)
}
```

The other errors are throws in both. In `uv.tcp.serve`, as in
`UV_TCP_Server`, an error in a client ends that client only.

### Buffers

In Céu, a stream has one buffer (a vector) that the program sees: a read
appends to it, a write sends it, and the program clears it. An echo is
two lines with no data in sight, and the echo of a line needs three
copies to preserve what was read ahead:

```
// Céu (tcp-10)
var[] byte line;
var usize n = await UV_Stream_Read_Line(&client.stream, &line);
line = line .. [{'\n'},{'\0'}];
var[] byte tmp = []..client.stream.buffer;  // TODO[-]: full-duplex
$line = $line-1;
client.stream.buffer = []..line;
await UV_Stream_Write_N(&client.stream, _);
client.stream.buffer = []..tmp;             // TODO[i]: full-duplex
```

```
;; Atmos
val line = await uv.stream.line(client)
until line == nil
await uv.stream.write(client, line ++ "\n")
```

Here the buffer of a stream is hidden, and what is read is a string, an
immutable value. Céu makes memory explicit: its buffers have a size
chosen by the program (`UV_TCP_Open(BUFFER_MAX)`), and a sample exists to
show what happens when it overflows. Here a buffer grows as needed, and a
line with no end grows without limit: a limit is not offered yet.

### Abortion

Both languages abort an operation by ending the block that awaits it,
and this is what the two have most in common:

```
// Céu (tcp-08)
watching 5s do
    await UV_TCP_Server(_, PORT+1, BACKLOG, _, _);
end
```

```
;; Atmos
watching 5s {
    await Server("0.0.0.0", 7001)
}
```

In both, the server, its pool of clients, and their connections end when
the five seconds pass, and the clients on the other side read the end.
In Céu the `finalize` clauses of each level do it; here, the pool is
pinned in the task of the server, and each connection belongs to its
task.

### What is missing here

- **Threads**: `await async/thread` of Céu runs a block in another thread
  (`timer-02`, `threads-01`). Atmos has no such construct.
- **Static bounds**: a pool in Céu has its memory reserved
  (`pool[10] Client cs`); `tasks(10)` only limits the number of tasks.
- **Buffers with a limit**, as above.
