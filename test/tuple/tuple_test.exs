defmodule MyElixirRayTracerTest.Tuple do
  use ExUnit.Case
  doctest MyElixirRayTracer.Tuple

  import MyElixirRayTracer.Tuple
  alias MyElixirRayTracer.Tuple

  test "A tuple with w=1.0 is a point" do
    a = %Tuple { x: 4.3, y: -4.2, z: 3.1, w: 1.0 }
    assert a.x == 4.3
    assert a.y == -4.2
    assert a.z == 3.1
    assert a.w == 1.0
    assert isAPoint(a) == true
    assert isAVector(a) == false
  end

  test "A tuple with w=1.0 is a vector" do
    a = %Tuple { x: 4.3, y: -4.2, z: 3.1, w: 0.0 }
    assert a.x == 4.3
    assert a.y == -4.2
    assert a.z == 3.1
    assert a.w == 0.0
    assert isAPoint(a) == false
    assert isAVector(a) == true
  end

  test "point() creates tuples with w=1" do
    p = point(4, -4, 3)
    assert p.w == 1
    assert isAPoint(p) == true
    assert isAVector(p) == false
  end

  test "vector() creates tuples with w=0" do
    p = vector(4, -4, 3)
    assert p.w == 0
    assert isAPoint(p) == false
    assert isAVector(p) == true
  end

  test "Adding two tuples" do
    a = point 3, -2, 5
    b = vector -2, 3, 1
    s = plus a, b
    assert s.x == 1
    assert s.y == 1
    assert s.z == 6
    assert isAPoint(s)
  end

  test "Subtracting two points" do
    p1 = point(3, 2, 1)
    p2 = point(5, 6, 7)
    r = minus(p1, p2)
    assert r.x == -2
    assert r.y == -4
    assert r.z == -6
    assert isAVector(r)
  end

  test "Subtracting a vector from a point" do
    p = point(3, 2, 1)
    v = vector(5, 6, 7)
    r = minus(p, v)
    assert r.x == -2
    assert r.y == -4
    assert r.z == -6
    assert isAPoint(r)
  end

  test "Subtracting two vectors" do
    v1 = vector(3, 2, 1)
    v2 = vector(5, 6, 7)
    r = minus(v1, v2)
    assert r.x == -2
    assert r.y == -4
    assert r.z == -6
    assert isAVector(r)
  end

  test "Subtracting a vector from the zero vector" do
    z = vector 0, 0, 0
    v = vector 1, -2, -3
    r = minus z, v
    assert r.x == -1
    assert r.y == 2
    assert r.z == 3
    assert isAVector(r)
  end

  test "Negating a tuple" do
    a = %Tuple { x: 1, y: -2, z: 3, w: -4 }
    n = negate(a)
    assert n.x == -1
    assert n.y == 2
    assert n.z == -3
    assert n.w == 4
  end

  test "Multiplying a tuple by a scalar" do
    a = %Tuple { x: 1, y: -2, z: 3, w: -4 }
    r = multiply(a, 3.5)
    assert r.x == 3.5
    assert r.y == -7
    assert r.z == 10.5
    assert r.w == -14
  end

  test "Multiplying a tuple by a fraction" do
    a = %Tuple { x: 1, y: -2, z: 3, w: -4 }
    r = multiply(a, 0.5)
    assert r.x == 0.5
    assert r.y == -1
    assert r.z == 1.5
    assert r.w == -2
  end

  test "Dividing a tuple by a scalar" do
    a = %Tuple { x: 1, y: -2, z: 3, w: -4 }
    r = divide(a, 2)
    assert r.x == 0.5
    assert r.y == -1
    assert r.z == 1.5
    assert r.w == -2
  end

  test "Computing the magnitude of vector(1, 0, 0)" do
    v = vector(1, 0, 0)
    r = magnitude(v)
    assert r == 1
  end

  test "Computing the magnitude of vector(0, 1, 0)" do
    v = vector(0, 1, 0)
    r = magnitude(v)
    assert r == 1
  end

  test "Computing the magnitude of vector(0, 0, 1)" do
    v = vector(0, 0, 1)
    r = magnitude(v)
    assert r == 1
  end

  test "Computing the magnitude of vector(1, 2, 3)" do
    v = vector(1, 2, 3)
    r = magnitude(v)
    assert r == :math.sqrt(14)
  end

  test "Computing the magnitude of vector(-1, -2, -3)" do
    v = vector(-1, -2, -3)
    r = magnitude(v)
    assert r == :math.sqrt(14)
  end

  test "Normalizing vector(4, 0, 0) gives (1, 0, 0)" do
    v = vector(4, 0, 0)
    assert normalize(v) == vector(1, 0, 0)
  end

  test "Normalizing vector(1, 2, 3)" do
    v = vector(1, 2, 3)
    m = magnitude(v)
    assert normalize(v) == vector(1/m, 2/m, 3/m)
  end

  test "The magnitude of a normalized vector" do
    v = vector(1, 2, 3)
    n = normalize(v)
    assert magnitude(n) == 1
  end

  test "The dot product of two tuples" do
    a = vector(1, 2, 3)
    b = vector(2, 3, 4)
    assert dot(a, b) == 20
  end

  test "The cross product of two vectors" do
    a = vector(1, 2, 3)
    b = vector(2, 3, 4)
    assert cross(a, b) == vector(-1, 2, -1)
    assert cross(b, a) == vector(1, -2, 1)
  end

end
