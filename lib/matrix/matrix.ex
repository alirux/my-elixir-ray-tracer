defmodule MyElixirRayTracer.Matrix do

  import MyElixirRayTracer.Common

  @doc """
  Difines a 4x4 matrix
  """
  def matrix4x4(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33) do
    %{ "r" => 4, "c" => 4,
       0.0 => m00, 0.1 => m01, 0.2 => m02, 0.3 => m03,
       1.0 => m10, 1.1 => m11, 1.2 => m12, 1.3 => m13,
       2.0 => m20, 2.1 => m21, 2.2 => m22, 2.3 => m23,
       3.0 => m30, 3.1 => m31, 3.2 => m32, 3.3 => m33,
     }
  end

  @doc """
  Difines a 2x2 matrix
  """
  def matrix2x2(m00, m01, m10, m11) do
    %{ "r" => 2, "c" => 2,
       0.0 => m00, 0.1 => m01,
       1.0 => m10, 1.1 => m11
     }
  end

  @doc """
  Difines a 3x3 matrix
  """
  def matrix3x3(m00, m01, m02, m10, m11, m12, m20, m21, m22) do
    %{ "r" => 3, "c" => 3,
       0.0 => m00, 0.1 => m01, 0.2 => m02,
       1.0 => m10, 1.1 => m11, 1.2 => m12,
       2.0 => m20, 2.1 => m21, 2.2 => m22
     }
  end

  def matrix_equals(m1, m2) do
    if m1["r"] != m2["r"] or m2["c"] != m2["c"] do
      false
    else
      matrix_equals(m1, m2, 0, 0)
    end

  end

  #alias Mix.Shell.IO, as: Shell

  defp matrix_equals(m1, m2, r, c) do
    # next indexes
    { new_r, new_c } = if c < m1["c"] - 1 do
      # same row, next column
      { r, c + 1 }
    else
      if r < m1["r"] - 1 do
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
      if new_r < m1["r"] do
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

end
