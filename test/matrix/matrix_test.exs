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

  test "Matrix equality with different matrices (different dimensions)" do
    m1 = matrix3x3(1, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9)
    m2 = matrix4x4(1, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 1600.5)
    assert matrix_equals(m1, m2) == [ equal: false ]
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
    assert matrix_determinant(m) == 17
  end

  test "A submatrix of a 3x3 matrix is a 2x2 matrix (0,2)" do
    m = matrix3x3(1, 5, 0, -3, 2, 7, 0, 6, -3)
    sub = matrix2x2(-3, 2, 0, 6)
    res = submatrix(m, 0, 2)
    assert matrix_equals(res, sub) ==  [ equal: true ]
    assert res[:nrows] == sub[:nrows]
    assert res[:ncols] == sub[:ncols]
  end

  test "A submatrix of a 3x3 matrix is a 2x2 matrix (0,0)" do
    m = matrix3x3(1, 5, 0,
                  -3, 2, 7,
                  0, 6, -3)
    sub = matrix2x2(2, 7, 6, -3)
    res = submatrix(m, 0, 0)
    assert matrix_equals(res, sub) ==  [ equal: true ]
    assert res[:nrows] == sub[:nrows]
    assert res[:ncols] == sub[:ncols]
  end

  test "A submatrix of a 3x3 matrix is a 2x2 matrix (2,2)" do
    m = matrix3x3(1, 5, 0,
                  -3, 2, 7,
                  0, 6, -3)
    sub = matrix2x2(1, 5, -3, 2)
    res = submatrix(m, 2, 2)
    assert matrix_equals(res, sub) ==  [ equal: true ]
    assert res[:nrows] == sub[:nrows]
    assert res[:ncols] == sub[:ncols]
  end

  test "A submatrix of a 4x4 matrix is a 3x3 matrix" do
    m = matrix4x4(-6, 1, 1, 6, -8, 5, 8, 6, -1, 0, 8, 2, -7, 1, -1, 1)
    sub = matrix3x3(-6, 1, 6, -8, 8, 6, -7, -1, 1)
    res = submatrix(m, 2, 1)
    assert matrix_equals(res, sub) ==  [ equal: true ]
    assert res[:nrows] == sub[:nrows]
    assert res[:ncols] == sub[:ncols]
  end

  # A minor of an alement at (row,col) of a matrix, is the determinant of the submatrix (row,col)
  test "Calculating a minor of a 3x3 matrix" do
    m = matrix3x3(3, 5, 0, 2, -1, -7, 6, -1, 5)
    assert matrix_minor(m, 1, 0) == 25
  end

  test "Calculating a cofactor of a 3x3 matrix" do
    m = matrix3x3(3, 5, 0, 2, -1, -7, 6, -1, 5)
    assert matrix_cofactor(m, 0, 0) == -12
    assert matrix_cofactor(m, 1, 0) == -25
  end

  test "Calculating the determinant of a 3x3 matrix" do
    m = matrix3x3(1, 2, 6, -5, 8, -4, 2, 6, 4)
    assert matrix_determinant(m) == -196
  end

  test "Calculating the determinant of a 4x4 matrix" do
    m = matrix4x4(-2, -8, 3, 5, -3, 1, 7, 3, 1, 2, -9, 6, -6, 7, 7, -9)
    assert matrix_determinant(m) == -4071
  end

  test "Testing an invertible matrix for invertibility" do
    m = matrix4x4(6, 4, 4, 4, 5, 5, 7, 6, 4, -9, 3, -7, 9, 1, 7, -6)
    assert matrix_is_invertible?(m) == true
  end

  test "Testing a noninvertible matrix for invertibility" do
    m = matrix4x4(-4, 2, -2, -3, 9, 6, 2, 6, 0, -5, 1, -5, 0, 0, 0, 0)
    assert matrix_is_invertible?(m) == false
  end

  test "Calculating the inverse of a matrix" do
    m = matrix4x4(-5, 2, 6, -8, 1, -5, 1, 8, 7, 7, -6, -7, 1, -3, 7, 4)
    expected_inverse = matrix4x4(0.21805, 0.45113, 0.24060, -0.04511, -0.80827, -1.45677, -0.44361, 0.52068, -0.07895, -0.22368, -0.05263, 0.19737, -0.52256, -0.81391, -0.30075, 0.30639)
    { :ok, inverse } = matrix_inverse(m)
    assert matrix_equals(inverse, expected_inverse) == [ equal: true ]
  end

  test "Calculating the inverse of another matrix" do
    m = matrix4x4(8, -5, 9, 2, 7, 5, 6, 1, -6, 0, 9, 6, -3, 0, -9, -4)
    expected_inverse = matrix4x4(-0.15385, -0.15385, -0.28205, -0.53846, -0.07692, 0.12308, 0.02564, 0.03077, 0.35897, 0.35897, 0.43590, 0.92308, -0.69231, -0.69231, -0.76923, -1.92308)
    { :ok, inverse } = matrix_inverse(m)
    assert matrix_equals(inverse, expected_inverse) == [ equal: true ]
  end

  test "Calculating the inverse of a third matrix" do
    m = matrix4x4(9, 3, 0, 9, -5, -2, -6, -3, -4, 9, 6, 4, -7, 6, 6, 2)
    expected_inverse = matrix4x4(-0.04074, -0.07778, 0.14444, -0.22222, -0.07778, 0.03333, 0.36667, -0.33333, -0.02901, -0.14630, -0.10926, 0.12963, 0.17778, 0.06667, -0.26667, 0.33333)
    { :ok, inverse } = matrix_inverse(m)
    assert matrix_equals(inverse, expected_inverse) == [ equal: true ]
  end

  test "Multiplying a product by its inverse" do
    m1 = matrix4x4(3, -9, 7, 3, 3, -8, 2, -9, -4, 4, 4, 1, -6, 5, -1, 1)
    m2 = matrix4x4(8, 2, 2, 2, 3, -1, 7, 0, 7, 0, 5, 4, 6, -2, 0, 5)
    { :ok, c } = matrix_multiply(m1, m2)
    { :ok, m2_inverse } = matrix_inverse(m2)
    { :ok, res } = matrix_multiply(c, m2_inverse)
    assert matrix_equals(res, m1) == [ equal: true ]
  end

end
