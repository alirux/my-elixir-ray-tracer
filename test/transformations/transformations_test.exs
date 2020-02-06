defmodule MyElixirRayTracerTestr.Transformations do
  use ExUnit.Case
  doctest(MyElixirRayTracer.Transformations)

  import MyElixirRayTracer.Transformations
  import MyElixirRayTracer.Matrix

  test "Multiplying by a translation matrix" do
    t = identity_matrix4x4() |> translation(5, -3, 2)
    start_p = mpoint(-3, 4, 5)
    expected_end_p = mpoint(2, 1, 7)
    { :ok, res } = matrix_multiply(t, start_p)
    assert matrix_equals?(res, expected_end_p)
  end

  test "Multiplying by the inverse of a translation matrix" do
    t = identity_matrix4x4() |> translation(5, -3, 2)
    { :ok, t_inverse } = matrix_inverse(t)
    start_p = mpoint(-3, 4, 5)
    # Translated to the opposite direction
    expected_end_p = mpoint(-3 - (5), 4 - (-3), 5 - (2))
    { :ok, res } = matrix_multiply(t_inverse, start_p)
    assert matrix_equals?(res, expected_end_p), "The end point is wrong"
  end

  test "Translation does not affect vectors" do
    t = identity_matrix4x4() |> translation(5, -3, 2)
    v = mvector(-3, 4, 5)
    { :ok, res } = matrix_multiply(t, v)
    # Same vector
    assert matrix_equals?(res, v)
  end

  test "A scaling matrix applied to a point" do
    t = identity_matrix4x4() |> scaling(2, 3, 4)
    start_p = mpoint(-4, 6, 8)
    # Every coordinate multiplied
    expected_end_p = mpoint(2 * -4, 3 * 6, 4 * 8)
    { :ok , res } = matrix_multiply(t, start_p)
    assert matrix_equals?(res, expected_end_p), "Wrong end point"
  end

  test "A scaling matrix applied to a vector" do
    t = identity_matrix4x4() |> scaling(2, 3, 4)
    start_v = mvector(-4, 6, 8)
    expected_end_v = mvector(-8, 18, 32)
    { :ok, res } = matrix_multiply(t, start_v)
    assert matrix_equals?(res, expected_end_v), "Wrong end vector"
  end

  test "Multiplying by the inverse of a scaling matrix" do
    t = identity_matrix4x4() |> scaling(2, 3, 4)
    { :ok, inv } = matrix_inverse(t)
    start_v = mvector(-4, 6, 8)
    expected_end_v = mvector(-2, 2, 2)
    { :ok, res } = matrix_multiply(inv, start_v)
    assert matrix_equals?(res, expected_end_v)
  end

  test "Reflection is scaling by a negative value" do
    t = identity_matrix4x4() |> scaling(-1, 1, 1)
    start_p = mpoint(2, 3, 4)
    expected_end_p = mpoint(-2, 3, 4)
    { :ok, res } = matrix_multiply(t, start_p)
    assert matrix_equals?(res, expected_end_p)
  end

  test "Rotating a point around the x axis" do
    start_p = mpoint(0, 1, 0)
    half_quarter = identity_matrix4x4() |> rotation_x(:math.pi() / 4)
    full_quarter = identity_matrix4x4() |> rotation_x(:math.pi() / 2)
    expected_point = mpoint(0, :math.sqrt(2) / 2, :math.sqrt(2) / 2)
    { :ok, res } = matrix_multiply(half_quarter, start_p)
    assert matrix_equals?(res, expected_point), "Bad rotation"

    expected_point = mpoint(0, 0, 1)
    { :ok, res } = matrix_multiply(full_quarter, start_p)
    assert matrix_equals?(res, expected_point), "Bad rotation"
  end

  test "The inverse of an x-rotation rotates in the opposite direction" do
    start_p = mpoint(0, 1, 0)
    half_quarter = identity_matrix4x4() |> rotation_x(:math.pi() / 4)
    { :ok, inv } = matrix_inverse(half_quarter)
    expected_end_p = mpoint(0, :math.sqrt(2) / 2, -:math.sqrt(2) / 2)
    { :ok, res } = matrix_multiply(inv, start_p)
    assert matrix_equals?(res, expected_end_p), "Bad rotation"
  end

  test "Rotating a point around the y axis" do
    start_p = mpoint(0, 0, 1)
    half_quarter = identity_matrix4x4() |> rotation_y(:math.pi() / 4)
    full_quarter = identity_matrix4x4() |> rotation_y(:math.pi() / 2)
    expected_point = mpoint(:math.sqrt(2) / 2, 0, :math.sqrt(2) / 2)
    { :ok, res } = matrix_multiply(half_quarter, start_p)
    assert matrix_equals?(res, expected_point), "Bad rotation"

    expected_point = mpoint(1, 0, 0)
    { :ok, res } = matrix_multiply(full_quarter, start_p)
    assert matrix_equals?(res, expected_point), "Bad rotation"
  end

  test "Rotating a point around the z axis" do
    start_p = mpoint(0, 1, 0)
    half_quarter = identity_matrix4x4() |> rotation_z(:math.pi() / 4)
    full_quarter = identity_matrix4x4() |> rotation_z(:math.pi() / 2)
    expected_point = mpoint(-:math.sqrt(2) / 2, :math.sqrt(2) / 2, 0)
    { :ok, res } = matrix_multiply(half_quarter, start_p)
    assert matrix_equals?(res, expected_point), "Bad rotation"

    expected_point = mpoint(-1, 0, 0)
    { :ok, res } = matrix_multiply(full_quarter, start_p)
    assert matrix_equals?(res, expected_point), "Bad rotation"
  end

  test "A shearing transformation moves x in proportion to y" do
    start_p = mpoint(2, 3, 4)
    t = identity_matrix4x4() |> shearing(1, 0, 0, 0, 0, 0)
    expected_end_p = mpoint(5, 3, 4)
    { :ok, res } = matrix_multiply(t, start_p)
    assert matrix_equals?(res, expected_end_p), "Bad shearing transformation"
  end

  test "A shearing transformation moves x in proportion to z" do
    start_p = mpoint(2, 3, 4)
    t = identity_matrix4x4() |> shearing(0, 1, 0, 0, 0, 0)
    expected_end_p = mpoint(6, 3, 4)
    { :ok, res } = matrix_multiply(t, start_p)
    assert matrix_equals?(res, expected_end_p), "Bad shearing transformation"
  end

  test "A shearing transformation moves y in proportion to x" do
    start_p = mpoint(2, 3, 4)
    t = identity_matrix4x4() |> shearing(0, 0, 1, 0, 0, 0)
    expected_end_p = mpoint(2, 5, 4)
    { :ok, res } = matrix_multiply(t, start_p)
    assert matrix_equals?(res, expected_end_p), "Bad shearing transformation"
  end

  test "A shearing transformation moves y in proportion to z" do
    start_p = mpoint(2, 3, 4)
    t = identity_matrix4x4() |> shearing(0, 0, 0, 1, 0, 0)
    expected_end_p = mpoint(2, 7, 4)
    { :ok, res } = matrix_multiply(t, start_p)
    assert matrix_equals?(res, expected_end_p), "Bad shearing transformation"
  end

  test "A shearing transformation moves z in proportion to x" do
    start_p = mpoint(2, 3, 4)
    t = identity_matrix4x4() |> shearing(0, 0, 0, 0, 1, 0)
    expected_end_p = mpoint(2, 3, 6)
    { :ok, res } = matrix_multiply(t, start_p)
    assert matrix_equals?(res, expected_end_p), "Bad shearing transformation"
  end

  test "A shearing transformation moves z in proportion to y" do
    start_p = mpoint(2, 3, 4)
    t = identity_matrix4x4() |> shearing(0, 0, 0, 0, 0, 1)
    expected_end_p = mpoint(2, 3, 7)
    { :ok, res } = matrix_multiply(t, start_p)
    assert matrix_equals?(res, expected_end_p), "Bad shearing transformation"
  end

  test "Individual transformations are applied in sequence" do
    p = mpoint(1, 0, 1)
    ta = identity_matrix4x4() |> rotation_x(:math.pi() / 2)
    tb = identity_matrix4x4() |> scaling(5, 5, 5)
    tc = identity_matrix4x4() |> translation(10, 5, 7)
    { :ok, p2 } = matrix_multiply(ta, p)
    assert matrix_equals?(p2, mpoint(1, -1, 0))
    { :ok, p3 } = matrix_multiply(tb, p2)
    assert matrix_equals?(p3, mpoint(5, -5, 0))
    { :ok, p4 } = matrix_multiply(tc, p3)
    assert matrix_equals?(p4, mpoint(15, 0, 7))
  end

  test "Chained transformations must be applied in reverse order" do
    p = mpoint(1, 0, 1)
    t = identity_matrix4x4()
      |> rotation_x(:math.pi() / 2)
      |> scaling(5, 5, 5)
      |> translation(10, 5, 7)
    { :ok, p2 } = matrix_multiply(t, p)
    assert matrix_equals?(p2, mpoint(15, 0, 7))
  end

end
