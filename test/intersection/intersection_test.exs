defmodule MyElixirRayTracerTest.Intersection do
  use ExUnit.Case
  doctest(MyElixirRayTracer.Intersection)

  import MyElixirRayTracer.Intersection

  test "The hit, when all intersections have positive t" do
    s = MyElixirRayTracer.Sphere.sphere()
    i1 = intersection(1, s)
    i2 = intersection(2, s)
    xs = intersections([], i2)
      |> intersections(i1)
    hit = hit(xs)
    assert hit == i1
  end

  test "The hit, when some intersactions has negative t" do
    s = MyElixirRayTracer.Sphere.sphere()
    i1 = intersection(-1, s)
    i2 = intersection(1, s)
    xs = intersections(i2, i1)
    hit = hit(xs)
    assert hit == i2
  end

  test "The hit, when all intersactions have negative t" do
    s = MyElixirRayTracer.Sphere.sphere()
    i1 = intersection(-2, s)
    i2 = intersection(-1, s)
    xs = intersections(i2, i1)
    hit = hit(xs)
    assert hit == nil
  end

  test "The hit is always the lowest nonnegative intersaction" do
    s = MyElixirRayTracer.Sphere.sphere()
    i1 = intersection(5, s)
    i2 = intersection(7, s)
    i3 = intersection(-3, s)
    i4 = intersection(2, s)
    xs = intersections(i2, i1) |> intersections(i3) |> intersections(i4)
    hit = hit(xs)
    assert hit == i4
  end

end
