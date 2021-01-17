defmodule MyElixirRayTracerTest.Material do
  use ExUnit.Case
  doctest(MyElixirRayTracer.Material)

  import MyElixirRayTracer.Material
  import MyElixirRayTracer.Color

  test "The default material" do
    m = material()
    assert m.color == color(1, 1, 1)
    assert m.ambient == 0.1
    assert m.diffuse == 0.9
    assert m.specular == 0.9
    assert m.shininess == 200
  end
end
