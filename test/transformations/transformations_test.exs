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

end
