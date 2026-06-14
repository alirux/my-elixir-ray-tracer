defmodule MyElixirRayTracerTest.World do
  use ExUnit.Case

  doctest MyElixirRayTracer.World

  alias MyElixirRayTracer.World
  alias MyElixirRayTracer.Color
  alias MyElixirRayTracer.Transformations
  alias MyElixirRayTracer.Sphere
  alias MyElixirRayTracer.Matrix
  alias MyElixirRayTracer.Material
  alias MyElixirRayTracer.Ray
  alias MyElixirRayTracer.Tuple

  test "The default world" do
    def_world = World.default_world()

    material = Material.material(Color.color(0.8, 1.0, 0.6), 0.1, 0.7, 0.2, 200)
    s1 = Sphere.sphere(Matrix.identity_matrix4x4(), material)

    s2 = Sphere.sphere(Matrix.identity_matrix4x4() |> Transformations.scaling(0.5, 0.5, 0.5))

    assert Enum.member?(def_world.objects, s1)
    assert Enum.member?(def_world.objects, s2)
  end

  test "Intersect a world with a ray" do
    def_world = World.default_world()
    r = Ray.ray(Tuple.point(0, 0, -5), Tuple.vector(0, 0, 1))
    intersections = World.world_intersect(def_world, r)

    assert length(intersections) == 4
    assert Enum.at(intersections, 0).time == 4
    assert Enum.at(intersections, 1).time == 4.5
    assert Enum.at(intersections, 2).time == 5.5
    assert Enum.at(intersections, 3).time == 6
  end
end
