defmodule MyElixirRayTracerTest.Ray do
  use ExUnit.Case
  doctest(MyElixirRayTracer.Ray)

  import MyElixirRayTracer.Tuple
  import MyElixirRayTracer.Ray
  import MyElixirRayTracer.Sphere
  import MyElixirRayTracer.Transformations
  import MyElixirRayTracer.Matrix

  test "Creating and querying a ray" do
    origin = point(1, 2, 3)
    direction = vector(4, 5, 6)
    r = ray(origin, direction)
    assert r.origin == origin
    assert r.direction == direction
  end

  test "Computing a point from a distance" do
    ray = ray(point(2, 3, 4), vector(1, 0, 0))
    assert ray_position(ray, 0)   == point(2, 3, 4)
    assert ray_position(ray, 1)   == point(3, 3, 4)
    assert ray_position(ray, -1)  == point(1, 3, 4)
    assert ray_position(ray, 2.5) == point(4.5, 3, 4)
  end

  test "A ray intersect a sphere in two points" do
    ray = ray(point(0, 0, -5), vector(0, 0, 1))
    sphere = sphere()
    intersections = ray_intersect(sphere, ray)
    assert map_size(intersections) == 2
    assert intersections[0].time == 4.0
    assert intersections[0].object == sphere
    assert intersections[1].time == 6.0
    assert intersections[1].object == sphere
  end

  test "A ray intersect a sphere at a tangent" do
    ray = ray(point(0, 1, -5), vector(0, 0, 1))
    sphere = sphere()
    intersections = ray_intersect(sphere, ray)
    assert map_size(intersections) == 2
    assert intersections[0].time == 5.0
    assert intersections[0].object == sphere
    assert intersections[1].time == 5.0
    assert intersections[1].object == sphere
  end

  test "A ray misses a sphere" do
    ray = ray(point(0, 2, -5), vector(0, 0, 1))
    sphere = sphere()
    intersections = ray_intersect(sphere, ray)
    assert map_size(intersections) == 0
  end

  test "A ray originates inside a sphere" do
    ray = ray(point(0, 0, 0), vector(0, 0, 1))
    sphere = sphere()
    intersections = ray_intersect(sphere, ray)
    assert map_size(intersections) == 2
    assert intersections[0].time == -1.0
    assert intersections[0].object == sphere
    assert intersections[1].time == 1.0
    assert intersections[1].object == sphere
  end

  test "A sphere is behind a ray" do
    ray = ray(point(0, 0, 5), vector(0, 0, 1))
    sphere = sphere()
    intersections = ray_intersect(sphere, ray)
    assert map_size(intersections) == 2
    assert intersections[0].time == -6.0
    assert intersections[0].object == sphere
    assert intersections[1].time == -4.0
    assert intersections[1].object == sphere
  end

  test "Translating a ray" do
    ray = ray(point(1, 2, 3), vector(0, 1, 0))
    m = identity_matrix4x4() |> translation(3, 4, 5)
    ray_translated = ray_transform(ray, m)
    assert ray_translated.origin == point(4, 6, 8)
    assert ray_translated.direction == vector(0, 1, 0)
  end

  test "Scaling a ray" do
    ray = ray(point(1, 2, 3), vector(0, 1, 0))
    m = identity_matrix4x4() |> scaling(2, 3, 4)
    ray_translated = ray_transform(ray, m)
    assert ray_translated.origin == point(2, 6, 12)
    assert ray_translated.direction == vector(0, 3, 0)
  end

end
