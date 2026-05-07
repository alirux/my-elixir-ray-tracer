# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

An Elixir umbrella project implementing a ray tracer following "The Ray Tracer Challenge" by Jamis Buck, with a Phoenix LiveView web frontend that streams the rendered image row by row.

## Commands

All commands run from the umbrella root unless noted.

```bash
mix test                                                        # run all tests (both apps)
mix test apps/my_elixir_ray_tracer/test/matrix/matrix_test.exs # run a single test file
mix phx.server                                                  # start the web server at localhost:4000
iex -S mix phx.server                                          # start server with interactive shell
mix start                                                       # CLI ray trace, outputs to /tmp/sphere.ppm
MIX_ENV=prod mix release                                        # build a production release
```

## Architecture

Two apps in `apps/`:

**`my_elixir_ray_tracer`** — core ray tracer (no web dependencies)

The rendering pipeline: `Raytracer` → `Ray` → `Intersection` → `Material`/`PointLight` → `Canvas` → PPM file.

- `Tuple` — points (`w=1`) and vectors (`w=0`), all arithmetic, normalize, dot/cross product, reflect
- `Matrix` — struct `{:rows, :cols, :data}` where `data` is a flat tuple; element at `(r, c)` accessed via `elem(data, r * cols + c)`; supports multiply, transpose, determinant, inverse
- `Color` — RGB struct with arithmetic and Hadamard product
- `Common` — float equality with tolerance `0.00001`
- `Transformations` — translation, scaling, rotation, shearing as chainable matrix builders starting from `identity_matrix4x4()`
- `Sphere` — struct with `:transform`, `:inverse_transform`, `:inverse_transpose_transform`, `:material`; the two inverse fields are pre-computed at construction time (never recomputed per-pixel); always construct via `sphere/0,1,2` — never use the struct literal directly
- `Material` — Phong parameters; `lighting/5` computes full Phong shading
- `PointLight` — struct `{:position, :intensity}`
- `Ray` — struct `{:origin, :direction}`; `ray_intersect/2` uses `sphere.inverse_transform` directly (no per-call inversion)
- `Intersection` — struct `{:time, :object}`; `hit/1` returns the first non-negative hit
- `Canvas` — 2D pixel grid (map); `save_canvas/2` writes PPM
- `Raytracer` — two entry points: `trace/0` (PPM to disk) and `trace_streaming/2` (broadcasts rows via PubSub for the web frontend); uses `Task.async_stream` for row-level parallelism
- `World` — in progress; `world_intersect/2` is a stub returning `[]`
- `lib/exercises/` — standalone projectile/clock demos, not part of the pipeline

**`ray_tracer_web`** — Phoenix 1.8 LiveView frontend

- `TracerLive` — single LiveView; PubSub topic is scoped per session (`"raytracer:render:#{socket.id}"`), so each tab gets an independent render; "Start Render" button spawns a `Task` calling `Raytracer.trace_streaming/2`; rows arrive as `{:row_ready, %{y:, pixels:}}` and are forwarded to the browser via `push_event`; `terminate/2` cleans up the subscription on disconnect
- `RayCanvas` JS hook (`priv/static/assets/js/app.js`) — draws each row using `putImageData` on an HTML5 canvas
- Phoenix and LiveView JS are served as UMD bundles from their hex packages via `Plug.Static` at `/vendor/`; no asset build step (esbuild not used)
- PubSub server is `RayTracerWeb.PubSub` (owned by the web app); `trace_streaming/2` accepts it as a parameter so the core app has no web dependency

## Deployment

Configured for Gigalixir with Mix releases. Release name is `ray_tracer_web` and includes both umbrella apps. Required env vars: `SECRET_KEY_BASE`, `PHX_HOST`, `PHX_SERVER=true`.

## Key conventions

- `Sphere` must always be constructed via `sphere/0`, `sphere/1`, or `sphere/2` — the constructors pre-compute the inverse transforms. Creating a struct literal bypasses this and leaves those fields `nil`.
- The CSRF token must be passed to `LiveSocket` in `app.js` via `params: {_csrf_token: csrfToken}` — without it LiveView refuses to connect.
- Transformation chains start from `identity_matrix4x4()` and are built with `|>`.
