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
  alias MyElixirRayTracer.Intersection
  alias MyElixirRayTracer.Computations

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

  test "Precomputing the state of an intersection" do
    ray = Ray.ray(Tuple.point(0, 0, -5), Tuple.vector(0, 0, 1))
    shape = Sphere.sphere()
    i = Intersection.intersection(4, shape)
    comps = Computations.prepare_computations(i, ray)

    assert comps.t == i.time
    assert comps.object == shape
    assert comps.point == Tuple.point(0, 0, -1)
    assert comps.eyev == Tuple.vector(0, 0, -1)
    assert comps.normalv == Tuple.vector(0, 0, -1)
  end
end
