defmodule MyElixirRayTracer.Tuple do
  @moduledoc """
  Definition and operations on tuples, points and vectors
  """
  alias MyElixirRayTracer.Tuple;

  defstruct x: 0, y: 0, z: 0, w: 0

  def isAPoint(tuple) do
    tuple.w == 1
  end

  def isAVector(tuple) do
    tuple.w == 0
  end

  def point(x, y, z) do
    %Tuple { x: x, y: y, z: z, w: 1}
  end

  def vector(x, y, z), do: %Tuple { x: x, y: y, z: z, w: 0}

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
  def magnitude(a), do: :math.sqrt(:math.pow(a.x, 2) + :math.pow(a.y, 2) + :math.pow(a.z, 2) + :math.pow(a.w, 2))

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

end
