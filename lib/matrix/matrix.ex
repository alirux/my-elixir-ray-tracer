defmodule MyElixirRayTracer.Matrix do

  import MyElixirRayTracer.Common

  # Calculate the float index
  defp index(r, c) do
    r + c/10.0
  end

  # Extract the row from the idx
  defp idx_to_row(idx) do
    trunc(idx)
  end

  # Extract the col from the idx
  defp idx_to_col(idx) do
    row = idx_to_row(idx)
    round((idx - row) * 10)
  end

  @doc """
  Defines a 4x4 identity matrix
  """
  def identity_matrix4x4() do
    %{ :nrows => 4, :ncols => 4,
       0.0 => 1, 0.1 => 0, 0.2 => 0, 0.3 => 0,
       1.0 => 0, 1.1 => 1, 1.2 => 0, 1.3 => 0,
       2.0 => 0, 2.1 => 0, 2.2 => 1, 2.3 => 0,
       3.0 => 0, 3.1 => 0, 3.2 => 0, 3.3 => 1,
     }
  end

  @doc """
  Defines a 4x4 matrix
  """
  def matrix4x4(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33) do
    %{ :nrows => 4, :ncols => 4,
       0.0 => m00, 0.1 => m01, 0.2 => m02, 0.3 => m03,
       1.0 => m10, 1.1 => m11, 1.2 => m12, 1.3 => m13,
       2.0 => m20, 2.1 => m21, 2.2 => m22, 2.3 => m23,
       3.0 => m30, 3.1 => m31, 3.2 => m32, 3.3 => m33,
     }
  end

  @doc """
  Defines a 2x2 matrix
  """
  def matrix2x2(m00, m01, m10, m11) do
    %{ :nrows => 2, :ncols => 2,
       0.0 => m00, 0.1 => m01,
       1.0 => m10, 1.1 => m11
     }
  end

  @doc """
  Defines a 3x3 matrix
  """
  def matrix3x3(m00, m01, m02, m10, m11, m12, m20, m21, m22) do
    %{ :nrows => 3, :ncols => 3,
       0.0 => m00, 0.1 => m01, 0.2 => m02,
       1.0 => m10, 1.1 => m11, 1.2 => m12,
       2.0 => m20, 2.1 => m21, 2.2 => m22
     }
  end

  @doc """
  Defines a 4x1 matrix
  """
  def matrix4x1(m00, m10, m20, m30) do
    %{ :nrows => 4, :ncols => 1,
       0.0 => m00,
       1.0 => m10,
       2.0 => m20,
       3.0 => m30
     }
  end

  def matrix_equals(m1, m2) do
    if m1[:nrows] != m2[:nrows] or m2[:ncols] != m2[:ncols] do
      [ equal: false ]
    else
      matrix_equals(m1, m2, 0, 0)
    end

  end

  #alias Mix.Shell.IO, as: Shell

  # A matrix is a map: can we use Map or Enum modules?
  defp matrix_equals(m1, m2, r, c) do
    # next indexes
    { new_r, new_c } = if c < m1[:ncols] - 1 do
      # same row, next column
      { r, c + 1 }
    else
      if r < m1[:nrows] - 1 do
        # next row, first column
        { r + 1, 0 }
      else
        # last element: the next row doesn't exist
        { r + 1, 0 }
      end
    end

    # Check the current col and row
    idx = r + c/10.0
    #Shell.info("curr=(#{r}, #{c}) next=(#{new_r}, #{new_c}) idx=#{idx}")
    if equal(m1[idx], m2[idx]) do
      # Current elements are equal so let's analyze the next element
      # Check if all the elements are evaluated
      if new_r < m1[:nrows] do
        matrix_equals(m1, m2, new_r, new_c)
      else
        # All the previous elements were equal, so the two matrixes are equal
        [ equal: true ]
      end
    else
      # Elements are Different, close the recursion
      #Shell.info("Different: curr=(#{r}, #{c}) next=(#{new_r}, #{new_c})")
      [ equal: false, row: r, col: c, idx: idx, val1: m1[idx], val2: m2[idx] ]
    end
  end

  @doc """
  Multiply row x col two matrixes
  """
  def matrix_multiply(m1, m2) do
    if m1[:ncols] != m2[:nrows], do: { :error, "Number of columns in m1 must be equal to number of rows of m2"}
    { :ok, matrix_multiply_rc(m1, m2, 0, 0, 0, 0, %{ :nrows => m1[:nrows], :ncols => m2[:ncols]}, 0)}
  end

  defp matrix_multiply_rc(m1, m2, r1, c1, r2, c2, res, tot) do
    idx1 = index(r1, c1)
    idx2 = index(r2, c2)
    #Shell.info("(#{r1}, #{c1}) (#{r2}, #{c2}) #{idx1} #{idx2} #{tot}")
    f = m1[idx1] * m2[idx2]
    #Shell.info("(#{r1}, #{c1}) (#{r2}, #{c2}) #{idx1} #{idx2} #{tot + f}")
    cond do
      # STOP condition, full multiplication was completed: last m1 row and row, last m2 row and col. Add the last element and return the map
      r1 == m1[:nrows] - 1 and c1 == m1[:ncols] - 1 and r2 == m2[:nrows] - 1 and c2 == m2[:ncols] -1 -> Map.put(res, index(r1, c2), tot + f)

      # a single row x col product is running => same m1 row, next m2 col; same m2 col, next m2 row => accumulate the tot
      r1 <= m1[:nrows] - 1 and c1 < m1[:ncols] - 1 -> matrix_multiply_rc(m1, m2, r1, c1 + 1, r2 + 1, c2, res, tot + f)

      # The loop on a single m1 row is finished: a single m1 row was multiplied with a single m2 col
      # Continue until the last m2 col is reached (i.e c2 < m2[:ncols] - 1)
      # Last m1 col, row x col completed => same m1 row, m1 col reset to zero; reset m2 row to zero, next m2 col => add the new element and reset the tot
      r1 <= m1[:nrows] - 1 and c1 == m1[:ncols] - 1 and c2 < m2[:ncols] - 1 -> matrix_multiply_rc(m1, m2, r1, 0, 0, c2 + 1, Map.put(res, index(r1, c2), tot + f), 0)

      # The m2 col is the last one => a single m1 row was multiplied for ALL the m2 cols
      # Last m2 col, row x col completed => next m1 row, m1 col reset to zero; m2 row reset to zero, m2 col reset to zero => add the new element and reset the tot
      c2 == m2[:ncols] - 1 -> matrix_multiply_rc(m1, m2, r1 + 1, 0, 0, 0, Map.put(res, index(r1, c2), tot + f), 0)

    end
  end

  @doc """
  Transpose a matrix: swap the columns into rows
  """
  def matrix_transpose(m) do
    # Two piped operations:
    # 1) Enum.map return a list of {k, v} tuples
    # 2) Map.new transform a list of {k, v} tuples into a map of k => v
    Enum.map(m, fn
      # Swap col with row
      {idx, val} when is_float(idx) ->
        row = idx_to_row(idx)
        col = idx_to_col(idx)
        { index(col, row), val }
      # Swap c with r: the order doesn't matter bc Elixir is creating e new list.
      # Enum.map doesn't mute elements overwriting the old value
      {:ncols, val} -> {:nrows, val}
      {:nrows, val} -> {:ncols, val}
    end) |> Map.new()
    #Mix.Shell.IO.info("#{t}")
  end

  @doc """
  Calculate the determinant of a 2x2 matrix
  """
  def matrix_2x2determinant(m) do
    m[0.0] * m[1.1] - m[1.0] * m[0.1]
  end

  def submatrix(m, row, col) do
    t = Enum.reject(m, fn { k, _v } ->
      # Remove the row and the col
      #Mix.Shell.IO.info("#{k}-#{row}")
      cond do
        k == :ncols -> false
        k == :nrows -> false
        row == trunc(k) -> true
        col == round((k - trunc(k)) * 10) -> true
        true -> false
      end
    end)
    |> Enum.map(fn { idx, v } ->
      # Correct the other indexes
      if is_float(idx) do
        curr_row = idx_to_row(idx)
        # if the current row is > of the removed row, then the row index must be decremented
        new_row = if curr_row < row, do: curr_row, else: curr_row - 1
        curr_col = idx_to_col(idx)
        # same for a col
        new_col = if curr_col < col, do: curr_col, else: curr_col - 1
        # The new index is:
        new_idx = index(new_row, new_col)
        #Mix.Shell.IO.info("#{curr_row},#{curr_col} #{new_row},#{new_col} #{new_idx}")
        { new_idx, v }
      else
        # Decrement the :nrows and :ncols
        { idx, v - 1 }
      end
    end)
    |> Map.new()
    #Mix.Shell.IO.info("#{t}")
    t
  end

end
