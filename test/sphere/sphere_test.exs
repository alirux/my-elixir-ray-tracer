defmodule MyElixirRayTracerTest.Sphere do
  use ExUnit.Case
  doctest(MyElixirRayTracer.Sphere)

  import MyElixirRayTracer.Sphere
  import MyElixirRayTracer.Matrix
  import MyElixirRayTracer.Transformations

  test "A sphere's default transformation" do
    s = sphere()
    assert s.transform == identity_matrix4x4()
  end

  test "Changin sphere's transformation" do
    s = sphere()
    t = identity_matrix4x4() |> translation(2, 3, 4)
    new_s = set_transform(s, t)
    assert new_s.transform == t
  end

end
