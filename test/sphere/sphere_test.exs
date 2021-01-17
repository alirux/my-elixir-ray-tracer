defmodule MyElixirRayTracerTest.Sphere do
  use ExUnit.Case
  doctest(MyElixirRayTracer.Sphere)

  import MyElixirRayTracer.Sphere
  import MyElixirRayTracer.Matrix
  import MyElixirRayTracer.Transformations
  import MyElixirRayTracer.Tuple
  import MyElixirRayTracer.Material

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

  test "Computing the normal on a sqrt(3)/3" do
    s = sphere(identity_matrix4x4() |> rotation_y(:math.pi/4))
    n = sphere_normal_at(s, point(:math.sqrt(3)/3, :math.sqrt(3)/3, :math.sqrt(3)/3))
    assert tuple_equal?(n, vector(:math.sqrt(3)/3, :math.sqrt(3)/3, :math.sqrt(3)/3))
  end

  test "Computing the normal on a +1y" do
    s = sphere(identity_matrix4x4() |> translation(0, 1, 0))
    n = sphere_normal_at(s, point(0, 2, 0))
    assert tuple_equal?(n, vector(0, 1, 0))
  end

  @doc """
     ˆ y
     |
  ---+O--> x
     |
     |
  """
  test "Computing the normal on a +1y +pi/2x" do
    # The rotation is left-handed -> in the end the sphere is on the right of the y axis
    s = sphere(identity_matrix4x4() |> translation(0, 1, 0) |> rotation_x(:math.pi/2))
    n = sphere_normal_at(s, point(0, 0, 2))  # z >= 2
    assert tuple_equal?(n, vector(0, 0, 1))
    n = sphere_normal_at(s, point(0, 0, -1))  # z <= 0
    assert tuple_equal?(n, vector(0, 0, -1))

  end

  test "Computing the normal on a -1z" do
    s = sphere(identity_matrix4x4() |> translation(0, 0, -1))
    n = sphere_normal_at(s, point(0, 0, -2))
    assert tuple_equal?(n, vector(0, 0, -1))
  end

  test "Computing the normal on a scaled sphere" do
    s = sphere(identity_matrix4x4() |> scaling(1, 0.5, 1))
    n = sphere_normal_at(s, point(0, :math.sqrt(2)/2, -:math.sqrt(2)/2))
    assert tuple_equal?(n, vector(0, 0.97014, -0.24254))
  end

  test "Computing the normal on a scaled sphere 2" do
    s = sphere(identity_matrix4x4() |> scaling(1, 0.5, 1))
    n = sphere_normal_at(s, point(0, 0.5, 0))
    assert tuple_equal?(n, vector(0, 1, 0))
  end

  test "Computing the normal on a scaled sphere 3" do
    s = sphere identity_matrix4x4() |> scaling(1, 0.5, 1) |> rotation_z(:math.pi/2)
    n = sphere_normal_at s, point(0, 0, 20373) # doesn't care the z value, can be 0.5, 1, ...
    assert tuple_equal? n, vector(0, 0, 1)
  end

  test "Computing the normal on a traslated sphere 4" do
    s = sphere identity_matrix4x4() |> translation(0, 1, 0)
    n = sphere_normal_at s, point(1, 1, 0)
    assert tuple_equal? n, vector(1, 0, 0)
  end

  @doc """
     ˆ y
     |
  --O+---> x
     |
     |
  """
  test "Computing the normal on a traslated sphere 5" do
    # The rotation is left-handed -> in the end the sphere is on the left of the y axis
    s = sphere identity_matrix4x4() |> translation(0, 1, 0) |> rotation_z(:math.pi/2)
    n = sphere_normal_at s, point(-0.5, 0.5, 0)
    assert tuple_equal? n, vector(:math.sqrt(2)/2, :math.sqrt(2)/2, 0)
  end

  test "Computing the normal on a traslated sphere 6" do
    s = sphere identity_matrix4x4() |> translation(0, 1, 0)
    n = sphere_normal_at s, point(0.5, 1.5, 0)
    assert tuple_equal? n, vector(:math.sqrt(2)/2, :math.sqrt(2)/2, 0)
  end

  test "Computing the normal on a transformed sphere" do
    s = sphere identity_matrix4x4() |> translation(0, 1, 0) |> scaling(1, 0.5, 1)
    n = sphere_normal_at s, point(1, 0.5, 0)
    assert tuple_equal? n, vector(1, 0, 0)
  end

  test "A sphere has a default material" do
    s = sphere()
    assert s.material == material()
  end

  test "A sphere may be assigned a material" do
    s = sphere()
    m = material()
    m = %{m | ambient: 1}
    s = %{s | material: m}
    assert s.material == m
  end



end
