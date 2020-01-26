defmodule MyElixirRayTracerTestr.Matrix do
  use ExUnit.Case
  doctest(MyElixirRayTracer.Matrix)

  import MyElixirRayTracer.Matrix

  test "Constructing and inspecting a 4x4 matrix" do
    m = matrix4x4(1, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 16.5)
    assert m[0.0] == 1
    assert m[0.3] == 4
    assert m[1.0] == 5.5
    assert m[1.2] == 7.5
    assert m[2.2] == 11
    assert m[3.0] == 13.5
    assert m[3.2] == 15.5
  end

  test "A 2x2 matrix ought to be representable" do
    m = matrix2x2(-3, 5, 1, -2)
    assert m[0.0] == -3
    assert m[0.1] == 5
    assert m[1.0] == 1
    assert m[1.1] == -2
  end

  test "A 3x3 matrix ought to be representable" do
    m = matrix3x3(-3, 5, 0, 1, -2, -7, 0, 1, 1)
    assert m[0.0] == -3
    assert m[1.1] == -2
    assert m[2.2] == 1
  end

  test "Matrix equality with identical matrices" do
    m1 = matrix4x4(1, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 16.5)
    m2 = matrix4x4(1, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 16.5)
    assert matrix_equals(m1, m2) == [ equal: true ]
  end

  test "Matrix equality with different matrices (first elements differ)" do
    m1 = matrix4x4(1, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 16.5)
    m2 = matrix4x4(10, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 16.5)
    assert matrix_equals(m1, m2) == [ equal: false, row: 0, col: 0, idx: 0.0, val1: 1, val2: 10 ]
  end

  test "Matrix equality with different matrices (last column elemts differ)" do
    m1 = matrix4x4(1, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 16.5)
    m2 = matrix4x4(1, 2, 3, 400, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 16.5)
    assert matrix_equals(m1, m2) == [ equal: false, row: 0, col: 3, idx: 0.3, val1: 4, val2: 400 ]
  end

  test "Matrix equality with different matrices (last element of the matrix differ)" do
    m1 = matrix4x4(1, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 16.5)
    m2 = matrix4x4(1, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 1600.5)
    assert matrix_equals(m1, m2) == [ equal: false, row: 3, col: 3, idx: 3.3, val1: 16.5, val2: 1600.5 ]
  end

  test "Multiplying two matrices" do
    m1 = matrix4x4(1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2)
    m2 = matrix4x4(-2, 1, 2, 3, 3, 2, 1, -1, 4, 3, 6, 5, 1, 2, 7, 8)
    p = matrix4x4(20, 22, 50, 48, 44, 54, 114, 108, 40, 58, 110, 102, 16, 26, 46, 42)
    { :ok, mult } = matrix_multiply(m1, m2)
    res = matrix_equals(mult, p)
    assert res == [ equal: true ]
  end

  test "A matrix multiplied by a tuple" do
    m1 = matrix4x4(1, 2, 3, 4, 2, 4, 4, 2, 8, 6, 4, 1, 0, 0, 0, 1)
    t2 = matrix4x1(1, 2, 3, 1)
    p = matrix4x1(18, 24, 33, 1)
    { :ok, mult } = matrix_multiply(m1, t2)
    res = matrix_equals(mult, p)
    assert res == [ equal: true ]
  end

  test "Multiplying a matrix by the identity matrix" do
    m1 = matrix4x4(0, 1, 2, 4, 1, 2, 4, 8, 2, 4, 8, 16, 4, 8, 16, 32)
    identity = identity_matrix4x4()
    { :ok, mult } = matrix_multiply(m1, identity)
    # the result is the same original matrix
    res = matrix_equals(mult, m1)
    assert res == [ equal: true ]
  end

  test "Multiplying the identity matrix by a tuple" do
    m1 = identity_matrix4x4()
    t2 = matrix4x1(1, 2, 3, 1)
    { :ok, mult } = matrix_multiply(m1, t2)
    # the result is the same original tuple
    res = matrix_equals(mult, t2)
    assert res == [ equal: true ]
  end

  test "Transposing a matrix" do
    m = matrix4x4(0, 9, 3, 0,
                  9, 8, 0, 8,
                  1, 8, 5, 3,
                  0, 0, 5, 8)
    t = matrix4x4(0, 9, 1, 0,
                  9, 8, 8, 0,
                  3, 0, 5, 5,
                  0, 8, 3, 8)
    assert matrix_equals(matrix_transpose(m), t) == [ equal: true ]
  end

  test "Transposing the identity matrix" do
    assert matrix_equals(matrix_transpose(identity_matrix4x4()), identity_matrix4x4()) == [ equal: true ]
  end

  test "Transposing a non square matrix" do
    m = matrix4x1(0, 9, 3, 1)
    t = %{:nrows => 1, :ncols => 4, 0.0 => 0, 0.1 => 9, 0.2 => 3, 0.3 => 1 }
    assert matrix_equals(matrix_transpose(m), t) == [ equal: true ]
  end

  test "Calculating the determinant of a 2x2 matrix" do
    m = matrix2x2(1, 5, -3, 2)
    assert matrix_2x2determinant(m) == 17
  end

end
