# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

An Elixir ray tracer following "The Ray Tracer Challenge" by Jamis Buck. No external dependencies.

## Commands

```bash
mix test                          # run all tests
mix test test/matrix/matrix_test.exs  # run a single test file
mix start                         # run the ray tracer, outputs to /tmp/sphere.ppm
```

## Architecture

The pipeline is: `Raytracer` → `Ray` → `Intersection` → `Material`/`PointLight` → `Canvas` → PPM file.

**Math primitives**
- `Tuple` — points (`w=1`) and vectors (`w=0`), all arithmetic, normalize, dot/cross product, reflect
- `Matrix` — matrices stored as plain Elixir maps; element at row `r`, col `c` is keyed by the float `r + c/10.0` (e.g. `m[1.2]` is row 1, col 2). Supports multiply, transpose, determinant, cofactor, inverse
- `Common` — floating-point equality with tolerance `0.00001`
- `Color` — RGB struct with arithmetic and Hadamard product
- `Transformations` — translation, scaling, rotation (x/y/z axes), shearing as chainable matrix builders

**Scene objects**
- `Sphere` — struct with `:transform` (4×4 matrix) and `:material`; `sphere_normal_at/2` transforms the normal through the inverse-transpose
- `Material` — Phong parameters (ambient, diffuse, specular, shininess, color); `lighting/5` computes the full Phong shading
- `PointLight` — struct with `:position` and `:intensity`
- `Ray` — struct with `:origin` and `:direction`; `ray_intersect/2` applies the sphere's inverse transform to the ray before computing the quadratic discriminant
- `Intersection` — struct `{:time, :object}`; `hit/1` returns the first non-negative intersection from a sorted list

**Rendering**
- `Canvas` — 2D pixel grid backed by a map; `write_pixel/4` and `save_canvas/2` (PPM format)
- `Raytracer` — drives the scan loop; for each canvas pixel it casts a ray, finds the nearest hit, computes the Phong color, and writes the pixel. Output goes to `/tmp/sphere.ppm`

**In progress**
- `World` — container for a light and a list of objects; `world_intersect/2` is a stub returning `[]`

**Exercises** (`lib/exercises/`) — standalone demos (projectile, clock) that predate the full ray tracer; not part of the rendering pipeline.

## Key conventions

- Modules use `import` (not `alias`) to pull in sibling modules, making their constructors and functions available unqualified.
- Matrix cell access always uses the float key encoding: `matrix[row + col/10.0]`.
- Transformation chains start from `identity_matrix4x4()` and are built with `|>`.
