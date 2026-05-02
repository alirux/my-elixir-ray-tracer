defmodule MyElixirRayTracer.Matrix do

  import MyElixirRayTracer.Common
  require Integer

  # A matrix is stored as a struct with:
  #   rows  - number of rows
  #   cols  - number of columns
  #   data  - flat tuple of all elements in row-major order
  #           element at (r, c) = elem(data, r * cols + c)
  defstruct [:rows, :cols, :data]

  @doc """
  Build a matrix from a list of lists (row-major order)
  """
  def new(rows_list) when is_list(rows_list) do
    nrows = length(rows_list)
    ncols = length(hd(rows_list))
    data = rows_list |> List.flatten() |> List.to_tuple()
    %__MODULE__{rows: nrows, cols: ncols, data: data}
  end

  @doc """
  O(1) element access: returns the element at (r, c)
  """
  def at(%__MODULE__{cols: cols, data: data}, r, c) do
    elem(data, r * cols + c)
  end

  @doc """
  Defines a 4x4 identity matrix
  """
  def identity_matrix4x4() do
    new([[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]])
  end

  @doc """
  Defines a 4x4 matrix
  """
  def matrix4x4(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33) do
    new([[m00,m01,m02,m03],[m10,m11,m12,m13],[m20,m21,m22,m23],[m30,m31,m32,m33]])
  end

  @doc """
  Defines a 2x2 matrix
  """
  def matrix2x2(m00, m01, m10, m11) do
    new([[m00,m01],[m10,m11]])
  end

  @doc """
  Defines a 3x3 matrix
  """
  def matrix3x3(m00, m01, m02, m10, m11, m12, m20, m21, m22) do
    new([[m00,m01,m02],[m10,m11,m12],[m20,m21,m22]])
  end

  @doc """
  Defines a 4x1 matrix
  """
  def matrix4x1(m00, m10, m20, m30) do
    new([[m00],[m10],[m20],[m30]])
  end

  @doc """
  Defines a point (like Tuple) based on a 4x1 matrix
  """
  def mpoint(x, y, z) do
    new([[x],[y],[z],[1]])
  end

  @doc """
  Defines a vector (like Tuple) based on a 4x1 matrix
  """
  def mvector(x, y, z) do
    new([[x],[y],[z],[0]])
  end

  @doc """
  Matrix equivalence: all the elements must be equals

  Returns a keyword list with the following keywords:

  - equal
  - row
  - col
  - m1 value
  - m2 value

  """
  def matrix_equals(m1, m2) do
    if m1.rows != m2.rows or m1.cols != m2.cols do
      [equal: false]
    else
      mismatch =
        for(r <- 0..(m1.rows - 1), c <- 0..(m1.cols - 1), do: {r, c})
        |> Enum.find(fn {r, c} -> not equal(at(m1, r, c), at(m2, r, c)) end)
      case mismatch do
        nil ->
          [equal: true]
        {r, c} ->
          [equal: false, row: r, col: c, val1: at(m1, r, c), val2: at(m2, r, c)]
      end
    end
  end

  @doc """
  Are the two matrix equal?
  """
  def matrix_equals?(m1, m2) do
    e = matrix_equals(m1, m2)
    Keyword.get(e, :equal)
  end

  @doc """
  Multiply row x col two matrixes
  """
  def matrix_multiply(m1, m2) do
    if m1.cols != m2.rows do
      {:error, "Number of columns in m1 must be equal to number of rows of m2"}
    else
      data =
        for r <- 0..(m1.rows - 1), c <- 0..(m2.cols - 1) do
          Enum.reduce(0..(m1.cols - 1), 0, fn k, acc -> acc + at(m1, r, k) * at(m2, k, c) end)
        end |> List.to_tuple()
      {:ok, %__MODULE__{rows: m1.rows, cols: m2.cols, data: data}}
    end
  end

  @doc """
  Transpose a matrix: swap the columns into rows
  """
  def matrix_transpose(m) do
    data = for c <- 0..(m.cols - 1), r <- 0..(m.rows - 1), do: at(m, r, c)
    %__MODULE__{rows: m.cols, cols: m.rows, data: List.to_tuple(data)}
  end

  @doc """
  Calculate the determinant of a matrix
  """
  # The stop clause: we know how to calculate a determinant of a 2x2 matrix
  def matrix_determinant(%__MODULE__{rows: 2, cols: 2} = m) do
    at(m, 0, 0) * at(m, 1, 1) - at(m, 1, 0) * at(m, 0, 1)
  end
  # For all the other cases use Enum.reduce over the columns of row 0
  def matrix_determinant(m) do
    Enum.reduce(0..(m.cols - 1), 0, fn col, acc ->
      acc + at(m, 0, col) * matrix_cofactor(m, 0, col)
    end)
  end

  def submatrix(m, row, col) do
    rows =
      for r <- 0..(m.rows - 1), r != row do
        for c <- 0..(m.cols - 1), c != col, do: at(m, r, c)
      end
    new(rows)
  end

  @doc """
  A minor of an element at (row,col) of a matrix, is the determinant of the submatrix (row,col)

  Implemented only for 3x3 matrix
  """
  def matrix_minor(m, row, col) do
    sub = submatrix(m, row, col)
    matrix_determinant(sub)
  end

  @doc """
  A cofactor (row,col) is a minor (row,col) of a matrix with the sign changed if row+col is an odd number
  """
  def matrix_cofactor(m, row, col) do
    minor = matrix_minor(m, row, col)
    if Integer.is_odd(row + col), do: -minor, else: minor
  end

  @doc """
  A matrix is invertible if its determinant is not equal to zero
  """
  def matrix_is_invertible?(m) do
    matrix_determinant(m) != 0
  end

  @doc """
  The inverse of a matrix
  """
  def matrix_inverse(m) do
    d = matrix_determinant(m)
    if d == 0 do
      {:error, "Matrix is not invertible"}
    else
      # transpose of cofactor matrix divided by determinant
      data =
        for c <- 0..(m.rows - 1), r <- 0..(m.cols - 1) do
          matrix_cofactor(m, r, c) / d
        end |> List.to_tuple()
      {:ok, %__MODULE__{rows: m.rows, cols: m.cols, data: data}}
    end
  end

  @doc """
  The inverse of a matrix. If it's not invertible an exception occurred
  """
  def matrix_inverse!(m) do
    with {:ok, inverse} = matrix_inverse(m) do
      inverse
    end
  end

end
