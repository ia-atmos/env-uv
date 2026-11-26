# Guide: env-uv

A tour of the environment by examples. The reference is [api.md](api.md).

```
$ make                      # builds ./atmos-uv
$ ./atmos-uv prog.atm
```

## Time

A program in this environment is an Atmos program whose time is the clock
of libuv. Nothing of libuv appears:

```
loop i in (1, 5) {
    await 1s
    print(i ++ "s elapsed...")
}
```

## A client

A connection is a value, and an operation that waits is a task that the
program awaits:

```
pin c = await uv.tcp.connect("localhost", 7000)
await uv.stream.write(c, "hello\n")
val line = await uv.stream.line(c)
print(line)
```

The `pin` gives the connection the life of its block: it closes when the
block ends, in any way.

## A timeout

There is no timeout in the operations: the language has it.
A `watching` aborts its block when the time passes, and the connection
that the block pins closes with it:

```
val ok, line = watching 5s {
    pin c = await uv.tcp.connect("localhost", 7000)
    await uv.stream.write(c, "hello\n")
    await uv.stream.line(c)
}
print(if ok => line => "no answer in 5s")
```

A `watching` gives a boolean before its values, as a `catch` does: `true`
and the values of the block, or `false` when the time passed first.

The same holds for any other reason to give up. This races two servers
and keeps the first answer, aborting the other connection:

```
task Ask (host) {
    pin c = await uv.tcp.connect(host, 7000)
    await uv.stream.write(c, "hello\n")
    await uv.stream.line(c)
}

val line = par :any {
    await Ask("server-1")
} with {
    await Ask("server-2")
}
```

## A server

A server is a loop that accepts connections, with a task for each one, in
a pool:

```
task Client (s) {
    loop {
        val line = await uv.stream.line(s)
        until line == nil               ;; the client closed
        await uv.stream.write(s, line ++ "\n")
    }
}

pin srv = uv.tcp.listen("0.0.0.0", 7000)
pin cs  = tasks()
loop {
    spawn @cs Client(await uv.tcp.accept(srv))
}
```

- The connection goes straight from the accept to its task, which owns
  it: it closes when the task ends. A connection pinned in the body of
  the loop could not go to a task of the pool, which lives outside.
- `tasks(100)` limits the server to 100 clients at a time: a `spawn` into
  a full pool evaluates to `nil`, and the connection closes.
- Aborting the block of `srv` and `cs` stops the server and closes every
  connection.

`await uv.tcp.serve(srv, Client)` is this loop, and it also confines an
error of libuv in a client to that client.

## Tasks that talk: a chat

The tasks of the clients communicate with events of the language. Each
client has two activities in parallel, and ends when the first one ends
([`exs/chat.atm`](../exs/chat.atm)):

```
task Client (s, id) {
    par :any {
        ;; from this client to the others
        loop {
            val line = await uv.stream.line(s)
            until line == nil
            emit @:global (:msg [from=id, text=line])
        }
    } with {
        ;; from the others to this client
        loop e on :msg {
            if e.from != id {
                await uv.stream.write(s, e.from ++ "> " ++ e.text ++ "\n")
            }
        }
    }
    emit @:global (:msg [from=id, text="(left)"])
}

pin srv = uv.tcp.listen("0.0.0.0", 7000)
pin cs  = tasks()
loop id {
    spawn @cs Client(await uv.tcp.accept(srv), id)
}
```

There is no list of clients: the pool is the list, and a client that
leaves is a task that ends.

## Files

A file is read and written as a stream, with a position:

```
pin src = await uv.fs.open("in.txt")
pin dst = await uv.fs.open("out.txt", "w")
loop {
    val line = await uv.fs.line(src)
    until line == nil
    await uv.fs.write(dst, line ++ "\n")
}
```

The program does not block while a file is read: the other tasks execute.

## Programs

A program runs as a process with three streams. This one sorts lines with
`sort`, and gives up if it takes more than a second:

```
pin p = uv.proc.spawn("sort")
await uv.stream.write(p.stdin, "b\nc\na\n")
await uv.stream.shutdown(p.stdin)           ;; the end of its input
watching 1s {
    loop {
        val line = await uv.stream.line(p.stdout)
        until line == nil
        print(line)
    }
    print("code", (await uv.proc.wait(p.proc)).code)
}
```

If the `watching` gives up, the block ends and `p` goes with it: a
process that still runs is terminated.

## Datagrams

UDP has no connection: a socket sends to an address and receives from
any:

```
pin u = uv.udp.bind("0.0.0.0", 9000)
loop {
    val d = await uv.udp.recv(u)            ;; [data, ip, port]
    await uv.udp.send(u, d@1, d@2, "echo: " ++ d@0)
}
```

## Signals

A signal is an event like the others. This server stops on `SIGINT`
(Ctrl-C) or `SIGTERM`, and its connections close with it:

```
par :any {
    await uv.signal.wait(2)                 ;; SIGINT
} with {
    await uv.signal.wait(15)                ;; SIGTERM
} with {
    pin srv = uv.tcp.listen("0.0.0.0", 7000)
    await uv.tcp.serve(srv, Client)
}
print("bye")
```

## With a GUI

The network and a GUI of [env-iup](https://github.com/ia-atmos/env-iup)
live in one program: the GUI is included first, so that it waits for its
events and gives the time, and libuv only delivers what is ready at each
of its steps. A button sends a text to a server, and a label shows the
answer ([`tst/pair/iup-echo.atm`](../tst/pair/iup-echo.atm)):

```
include "iup.atm"
include "uv.atm"

pin c = await uv.tcp.connect("localhost", 7000)
loop on :action [h=but] {
    await uv.stream.write(c, iup.get(txt, "VALUE") ++ "\n")
    iup.set(lbl, "TITLE", (await uv.stream.line(c)))
}
```

It is built with the plain compiler and the flags of both libraries, since
`atmos-uv` would make libuv the first environment. The network then has
the latency of a step of the GUI (10ms).

## Errors

An error of libuv is a throw with its name, and the end of a stream or of
a file is the value `nil`:

```
val ok, e = catch :error {
    pin f = await uv.fs.open("/non/existent/path")
    ...
}
if !ok {
    print("open error: " ++ e.name)     ;; --> open error: ENOENT
}
```

`catch :error.ENOENT {...}` catches that error only. The blocks in
course terminate as usual, so what they pin closes.

## More

- [`samples/`](../samples): the samples of ceu-libuv, and
  [ceu.md](ceu.md), which compares them with the originals.
- [`exs/http.atm`](../exs/http.atm): a small HTTP server, with a timeout
  per request.
- [`tst/`](../tst): each operation aborted in the middle
  (`tcp-abort.atm`, `fs-abort.atm`), and the errors (`tcp-error.atm`).
