defmodule MyElixirRayTracer.Color do
  @moduledoc """
  Definition of color model with operations
  """

  alias MyElixirRayTracer.Color

  @doc """
  Color model
  """
  defstruct red: 0, green: 0, blue: 0

  @doc """
  Creates a color
  """
  def color(red, green, blue), do: %Color { red: red, green: green, blue: blue }

  @doc """
  Add two colors
  """
  def add(c1, c2), do: %Color { red: c1.red + c2.red, green: c1.green + c2.green, blue: c1.blue + c2.blue }

  @doc """
  Subtract two colors
  """
  def minus(c1, c2), do: %Color { red: c1.red - c2.red, green: c1.green - c2.green, blue: c1.blue - c2.blue }

  @doc """
  Multiply a color by a scalar
  """
  def multiply(c, s), do: %Color { red: c.red * s, green: c.green * s, blue: c.blue * s }

  @doc """
  Hadamard product of two colors
  """
  def hadamard_prod(c1, c2), do: %Color { red: c1.red * c2.red, green: c1.green * c2.green, blue: c1.blue * c2.blue }

end
