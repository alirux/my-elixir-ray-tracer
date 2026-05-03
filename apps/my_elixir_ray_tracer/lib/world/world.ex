defmodule MyElixirRayTracer.World do

  alias MyElixirRayTracer.PointLight
  alias MyElixirRayTracer.Color
  alias MyElixirRayTracer.Transformations
  alias MyElixirRayTracer.Tuple, as: RTTuple
  alias MyElixirRayTracer.Sphere
  alias MyElixirRayTracer.Matrix
  alias MyElixirRayTracer.Material

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
    light = PointLight.point_light(RTTuple.point(-10, 10, -10), Color.color(1, 1, 1))
    material = Material.material(Color.color(0.8, 1.0, 0.6), 0.1, 0.7, 0.2, 200)
    s1 = Sphere.sphere(Matrix.identity_matrix4x4(), material)

    s2 = Sphere.sphere(Matrix.identity_matrix4x4() |> Transformations.scaling(0.5, 0.5, 0.5))
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
