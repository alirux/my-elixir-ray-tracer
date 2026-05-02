defmodule MyElixirRayTracer.World do

  import MyElixirRayTracer.PointLight
  import MyElixirRayTracer.Color
  import MyElixirRayTracer.Transformations
  import MyElixirRayTracer.Tuple
  import MyElixirRayTracer.Sphere
  import MyElixirRayTracer.Matrix
  import MyElixirRayTracer.Material

  defstruct light: nil, objects: []

  @doc """
  A world with a light and no objects
  """
  def world(light) do
    %MyElixirRayTracer.World { light: light }
  end

  @doc """
  Creates a default world
  """
  def default_world() do
    light = point_light(point(-10, 10, -10), color(1, 1, 1))
    material = material(color(0.8, 1.0, 0.6), 0.1, 0.7, 0.2, 200)
    s1 = sphere(identity_matrix4x4(), material)

    s2 = sphere(identity_matrix4x4() |> scaling(0.5, 0.5, 0.5))
    %MyElixirRayTracer.World { light: light, objects: [ s1 | [ s2 ] ] }
  end

  @doc """
  Intersect the ray with all the objects in the world.any()

  Returns the intersections found, sorted by time ascending
  """
  def world_intersect(_world, _ray) do
    []
  end

end
