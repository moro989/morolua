# morolua

A small, engine‑agnostic **utility library for Lua**, focused on clarity, safety, and game‑adjacent ergonomics with **no dependecies**.

morolua is **not** a framework. It does not try to control your architecture, your update loop, or your style. It exists to remove friction from plain Lua code, especially in game‑like environments.

---

## ✨ Goals

* Pure Lua (no dependencies)
* Engine‑agnostic (LOVE2D, Roblox‑style Lua, plain Lua)
* Clarity over cleverness
* Small, composable helpers
* Explicit behavior and documented footguns

If you want a framework, ECS, class system, or heavy abstractions, this is **not** that.

---

## 📦 Modules

morolua is split into small, focused modules. You can require them individually or require as a whole from morolua.init.lua file.

The modules are intentionally ordered from **lowest‑level primitives** to **higher‑level behavior**.

### `mathx`

Extra math helpers missing from standard Lua.

* clamp, lerp, ranges
* numeric predicates and helpers
* small convenience utilities

### `stringx`

Utility helpers for working with strings safely and explicitly.

* empty / nil checks
* prefix & suffix checks
* common string predicates
* features buffers
* custom stringx.utf8 implementation instead of Lua’s utf8 module, so it works on Lua versions older than 5.3.

### `typex`

Runtime type helpers beyond `type()`.

* strict type checks
* compound type validation
* readable type errors

### `assertx`

Strict assertion helpers for validating inputs.

* type assertions
* non‑empty checks
* descriptive error messages

Used internally by morolua to harden APIs.

### `iterx`

Iteration utilities for tables and sequences.

* functional‑style iteration helpers
* safer loops and predicates
* features generators

### `coroutinex`

Quality‑of‑life helpers around Lua coroutines.

* safe resume wrappers
* coroutine state helpers
* error‑aware execution

### `oopx`

Minimal helpers for object‑style programming.

* constructor patterns
* prototype helpers
* **not** a full OOP framework


---

### `tablex`

Table utilities with **explicit behavior**.

Includes:

* shallow copy/deep copy helpers (with clear limitations) helpers
* basic table helpers

Important:

> `deepCopy` does **not** magically handle cycles or metatables unless explicitly documented.

---

### `eventx`

A lightweight event / signal system inspired by Roblox‑style events, without engine lock‑in.

Example:

```lua
local ev = eventx.new()

ev:on("message", function(msg)
    print(msg)
end)

ev:emit("message", "hello world")
```

Supports one‑time listeners and explicit lifecycle control.

---

### `taskx`

A cooperative task scheduler built on Lua coroutines.

Designed for:

* game loops
* cooperative async logic
* explicit update‑driven scheduling

This is **not** multithreading.
All tasks run on the main thread.

### 'async'
A small convenience layer built on top of `taskx` that provides a **sync / async friendly API**.

`asyncx` does **not** introduce a new scheduler.  
It exists to make coroutine-based async code easier to write and reuse, especially when the same function may be called both synchronously and asynchronously.

Includes:

* async task spawning
* synchronous waiting (`await`)
* sync-or-async function calls
* small helpers (`sleep`, `defer`, `all`, `race`)

Important:

> `asyncx` uses `taskx` as its **default scheduler**.  
> If no custom scheduler is provided, `taskx` will be required and used automatically.

`asyncx` is cooperative and update-driven.  
It does **not** create threads and will not run unless the scheduler is being updated.

---

## 📁 Installation

### Option 1: Copy files directly

Copy the `morolua/` folder into your project and require what you need.

```lua
local morolua = require("morolua.init") --init gets everymodule
local stringx = morolua.stringx
--or you can do
local eventx = require("morolua.core.eventx")
uievents = eventx.new()
--to only get the part(s) you want
```

### Option 2: Git submodule

```sh
git submodule add https://github.com/moro989/morolua
```

---

## 🚫 What morolua intentionally does NOT include

* No class / OOP framework
* No ECS
* No physics, rendering, or input helpers
* No networking
* No configuration system
* No promises / futures

These belong in **other libraries**, not here.

---

## 🧪 Testing

morolua includes simple tests to verify behavior.

Tests focus on:

* correct behavior
* misuse cases
* regression prevention

Green tests are required before releases.

---

## 📜 License

MIT License. Do whatever you want, just don’t blame me.

---

## 🧭 Project Philosophy

* Helpers, not frameworks
* Explicit > implicit
* Boring code is good code
* If behavior is dangerous, it must be loud

---

## 📌 Status

Current version: **v0.1.0**

APIs may evolve until v1.0.0, after which breaking changes will follow semantic versioning.

---

If morolua saves you even a little bit of brainpower, it did its job.
