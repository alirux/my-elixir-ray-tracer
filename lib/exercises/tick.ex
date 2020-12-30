defmodule MyElixirRayTracer.Exercises.Tick do
  @moduledoc """
  Exercise: fire e projectile
  """
  import MyElixirRayTracer.Tuple
  alias MyElixirRayTracer.Exercises.Projectile
  alias MyElixirRayTracer.Exercises.Environment
  #alias MyElixirRayTracer.Tuple
  alias Mix.Shell.IO, as: Shell
  #alias MyElixirRayTracer.Canvas
  import MyElixirRayTracer.Canvas
  import MyElixirRayTracer.Color

  @doc """
  ### Calculate the new projectile after a "tick" of time.
  - A tick is a unit of time, may be seconds or milliseconds.
  - The position of the projectile is measured in whatever unit (m, mm, ...).
  - The velocity is measured in position unit per tick (e.g. m/s).
  - Acceleration (gravity and wind) are measured in position unit per tick ˆ2 (e.g. m/sˆ2).
  So:
  - The new position is the current position plus the velocity multiplied by a single tick.
  - The new velocity is the current velocity plus the gravity and the wind multiplied by a single tick.
  """
  def tick(env, proj) do
    #Shell.info("p=[#{proj.position.x}, #{proj.position.y}, #{proj.position.z}, #{proj.position.w}], v=[#{proj.velocity.x}, #{proj.velocity.y}, #{proj.velocity.z}, #{proj.velocity.w}]")
    position = plus(proj.position, proj.velocity)
    velocity = plus(proj.velocity, env.gravity) |> plus(env.wind)
    %Projectile { position: position, velocity: velocity }
  end

  @doc """
  Fire the projectile in the environment and see when the projectile hit the ground
  """
  def fire(env, proj, canvas) do
    cx = min(round(proj.position.x), canvas.width - 1)
    cy = max(min(canvas.height - round(proj.position.y), canvas.height - 1), 0)
    Shell.info("Canvas=[#{cx}, #{cy}] p=[#{proj.position.x}, #{proj.position.y}, #{proj.position.z}, #{proj.position.w}], v=[#{proj.velocity.x}, #{proj.velocity.y}, #{proj.velocity.z}, #{proj.velocity.w}]")
    new_canvas = write_pixel(canvas, cx, cy, color(0.5, 0.5, 0.5))
    if proj.position.y > 0 do
      # The projectile is in flight: see what happens in the next tick
      r = tick(env, proj)
      fire(env, r, new_canvas)
    else
      # The projectile hit the ground (y <= 0)
      Shell.info("Saving canvas")
      save_canvas(canvas, "/tmp/pojectile_trajectory.ppm")
      proj
    end
  end

  @doc """
  Fire a projectile
  """
  def execute do
    env = %Environment { gravity: vector(0, -0.8, 0), wind: vector(-0.1, 0, 0)}
    proj = %Projectile { position: point(0, 1, 0), velocity: MyElixirRayTracer.Tuple.multiply(normalize(vector(1, 0.8, 0)), 17) }

    fire(env, proj, canvas(400, 100, color(1, 1, 1)))
  end
end
