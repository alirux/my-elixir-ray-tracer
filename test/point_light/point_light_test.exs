defmodule MyElixirRayTracerTest.PointLight do
  use ExUnit.Case
  doctest(MyElixirRayTracer.PointLight)

  import MyElixirRayTracer.PointLight
  import MyElixirRayTracer.Tuple
  import MyElixirRayTracer.Color

  test "A point light has a position and intensity" do
    pos = point(0, 0, 0)
    intensity = color(1, 1, 1)
    point_light = point_light pos, intensity
    assert point_light.position == pos
    assert point_light.intensity == intensity
  end
end
