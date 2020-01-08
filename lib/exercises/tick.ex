defmodule MyElixirRayTracer.Exercises.Tick do
  import MyElixirRayTracer.Tuple
  alias MyElixirRayTracer.Exercises.Projectile
  alias MyElixirRayTracer.Exercises.Environment
  #alias MyElixirRayTracer.Tuple
  alias Mix.Shell.IO, as: Shell

  def tick(env, proj) do
    #Shell.info("p=[#{proj.position.x}, #{proj.position.y}, #{proj.position.z}, #{proj.position.w}], v=[#{proj.velocity.x}, #{proj.velocity.y}, #{proj.velocity.z}, #{proj.velocity.w}]")
    position = plus(proj.position, proj.velocity)
    velocity = plus(proj.velocity, env.gravity) |> plus(env.wind)
    %Projectile { position: position, velocity: velocity }
  end

  def fire(env, proj) do
    Shell.info("p=[#{proj.position.x}, #{proj.position.y}, #{proj.position.z}, #{proj.position.w}], v=[#{proj.velocity.x}, #{proj.velocity.y}, #{proj.velocity.z}, #{proj.velocity.w}]")
    if proj.position.y > 0 do
       r = tick(env, proj)
       fire(env, r)
    else
      proj
    end
  end

  def execute do
    env = %Environment { gravity: vector(0, -0.1, 0), wind: vector(-0.01, 0, 0)}
    proj = %Projectile { position: point(0, 1, 0), velocity: normalize(vector(1, 1, 0))}

    _r = fire(env, proj)
  end
end
