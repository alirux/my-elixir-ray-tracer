defmodule MyElixirRayTracerTest.Sphere do
  use ExUnit.Case
  doctest(MyElixirRayTracer.Sphere)

  import MyElixirRayTracer.Sphere
  import MyElixirRayTracer.Matrix
  import MyElixirRayTracer.Transformations
  import MyElixirRayTracer.Tuple

  test "A sphere's default transformation" do
    s = sphere()
    assert s.transform == identity_matrix4x4()
  end

  test "Changing sphere's transformation" do
    s = sphere()
    t = identity_matrix4x4() |> translation(2, 3, 4)
    new_s = set_transform(s, t)
    assert new_s.transform == t
  end

  test "The normal on a sphere at a point on the x axis" do
    s = sphere()
    n = sphere_normal_at(s, point(1, 0, 0))
    assert n == vector(1, 0, 0)
  end

  test "The normal on a sphere at a point on the y axis" do
    s = sphere()
    n = sphere_normal_at(s, point(0, 1, 0))
    assert n == vector(0, 1, 0)
  end

  test "The normal on a sphere at a point on the z axis" do
    s = sphere()
    n = sphere_normal_at(s, point(0, 0, 1))
    assert n == vector(0, 0, 1)
  end

  test "The normal on a sphere at a nonaxial point" do
    s = sphere()
    n = sphere_normal_at(s, point(:math.sqrt(3)/3, :math.sqrt(3)/3, :math.sqrt(3)/3))
    assert n == vector(:math.sqrt(3)/3, :math.sqrt(3)/3, :math.sqrt(3)/3)
  end

  test "The normal on a sphere is a normalized vector" do
    s = sphere()
    n = sphere_normal_at(s, point(:math.sqrt(3)/3, :math.sqrt(3)/3, :math.sqrt(3)/3))
    assert n == normalize(n)
  end

  test "Computing the normal on a translated sphere" do
    s = sphere(identity_matrix4x4() |> translation(0, 1, 0))
    n = sphere_normal_at(s, point(0, 1.70711, -0.70711))
    assert tuple_equal?(n, vector(0, 0.70711, -0.70711))
  end

  test "Computing the normal on a transformed sphere" do
    s = sphere(identity_matrix4x4() |> scaling(1, 0.5, 1))
    n = sphere_normal_at(s, point(0, :math.sqrt(2)/2, -:math.sqrt(2)/2))
    assert tuple_equal?(n, vector(0, 0.97014, -0.24254))
  end


end
