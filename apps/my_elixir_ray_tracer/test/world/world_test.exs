defmodule MyElixirRayTracerTest.World do
  use ExUnit.Case

  doctest MyElixirRayTracer.World

  import MyElixirRayTracer.World
  import MyElixirRayTracer.Color
  import MyElixirRayTracer.Transformations
  import MyElixirRayTracer.Sphere
  import MyElixirRayTracer.Matrix
  import MyElixirRayTracer.Material

  test "The default world" do
    def_world = default_world()

    material = material(color(0.8, 1.0, 0.6), 0.1, 0.7, 0.2, 200)
    s1 = sphere(identity_matrix4x4(), material)

    s2 = sphere(identity_matrix4x4() |> scaling(0.5, 0.5, 0.5))

    assert Enum.member?(def_world.objects, s1)
    assert Enum.member?(def_world.objects, s2)
  end
end
