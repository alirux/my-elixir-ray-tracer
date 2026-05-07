defmodule MyElixirRayTracer.Tuple do
  @moduledoc """
  Definition and operations on tuples, points and vectors
  """
  alias MyElixirRayTracer.Tuple;
  alias MyElixirRayTracer.Matrix
  #alias Mix.Shell.IO, as: Shell

  import MyElixirRayTracer.Common

  defstruct x: 0, y: 0, z: 0, w: 0

  def isAPoint(tuple) do
    tuple.w == 1
  end

  def isAVector(tuple) do
    tuple.w == 0
  end

  def tuple(x, y, z, w) do
    %Tuple { x: x, y: y, z: z, w: w}
  end

  def point(x, y, z) do
    %Tuple { x: x, y: y, z: z, w: 1.0}
  end

  def vector(x, y, z), do: %Tuple { x: x, y: y, z: z, w: 0.0}

  @doc """
  Add two Tuples a + b
  """
  def plus(a, b), do: %Tuple { x: a.x + b.x, y: a.y + b.y, z: a.z + b.z, w: a.w + b.w }

  @doc """
  Subtract two Tuples a - b
  """
  def minus(a, b), do: %Tuple { x: a.x - b.x, y: a.y - b.y, z: a.z - b.z, w: a.w - b.w }

  @doc """
  Negate a Tuple
  """
  def negate(a), do: %Tuple { x: -a.x, y: -a.y, z: -a.z, w: -a.w }

  @doc """
  Multiply a Tuple a by a scalar s
  """
  def multiply(a, s), do: %Tuple { x: s * a.x, y: s * a.y, z: s * a.z, w: s * a.w }

  @doc """
  Divide a Tuple a by a scalar s
  """
  def divide(a, s), do: %Tuple { x: a.x / s, y: a.y / s, z: a.z / s, w: a.w / s }

  @doc """
  Magnitude of a Tuple
  """
  def magnitude(a), do: :math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)

  @doc """
  Normalize a Tuple
  """
  def normalize(v) do
    m = magnitude(v)
    %Tuple { x: v.x / m, y: v.y / m, z: v.z / m, w: v.w / m }
  end

  @doc """
  Dot product of two Tuples (scalar product)
  """
  def dot(a, b) do
    a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
  end

  @doc """
  Cross product of two Tuples (scalar product)
  """
  def cross(a, b) do
    vector(a.y * b.z - a.z * b.y,
          a.z * b.x - a.x * b.z,
          a.x * b.y - a.y * b.x)
  end

  @doc """
  Transform the tuple (translation, scaling, ...) by multiplying the transformation matrix by the tuple.
  Pattern-matches all 16 matrix elements directly to avoid per-element function call overhead.
  """
  def tuple_transform(%{data: d}, %{x: x, y: y, z: z, w: w}) do
    {m00, m01, m02, m03,
     m10, m11, m12, m13,
     m20, m21, m22, m23,
     m30, m31, m32, m33} = d
    tuple(
      m00 * x + m01 * y + m02 * z + m03 * w,
      m10 * x + m11 * y + m12 * z + m13 * w,
      m20 * x + m21 * y + m22 * z + m23 * w,
      m30 * x + m31 * y + m32 * z + m33 * w
    )
  end

  @doc """
  Two tuples are "quite" equal (equal with tolerance)
  """
  def tuple_equal?(t1, t2) do
    equal(t1.x, t2.x) and equal(t1.y, t2.y) and equal(t1.z, t2.z) and equal(t1.w, t2.w)
  end

  @doc """
  Reflect the vector v by the normal
  """
  def reflect(v, normal) do
    minus v, multiply(normal, 2 * dot(v, normal))
  end

end
