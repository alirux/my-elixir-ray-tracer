defmodule MyElixirRayTracer.Color do
  @moduledoc """
  Definition of color model with operations
  """

  import MyElixirRayTracer.Common

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
  def color_add(c1, c2), do: %Color { red: c1.red + c2.red, green: c1.green + c2.green, blue: c1.blue + c2.blue }

  @doc """
  Subtract two colors
  """
  def color_minus(c1, c2), do: %Color { red: c1.red - c2.red, green: c1.green - c2.green, blue: c1.blue - c2.blue }

  @doc """
  Multiply a color by a scalar
  """
  def color_multiply(c, s), do: %Color { red: c.red * s, green: c.green * s, blue: c.blue * s }

  @doc """
  Hadamard product of two colors
  """
  def hadamard_prod(c1, c2), do: %Color { red: c1.red * c2.red, green: c1.green * c2.green, blue: c1.blue * c2.blue }

  @doc """
  Scale a decimal number to an integer number 0..255
  ### Examples
    iex> MyElixirRayTracer.Color.scale_color_component(-1)
    0

    iex> MyElixirRayTracer.Color.scale_color_component(2)
    255

    iex> MyElixirRayTracer.Color.scale_color_component(0)
    0

    iex> MyElixirRayTracer.Color.scale_color_component(1)
    255

    iex> MyElixirRayTracer.Color.scale_color_component(0.5)
    128
  """
  def scale_color_component(p) do
    d = min(p, 1.0)
    d = max(d, 0)
    round(255*d)
  end

  @doc """
  Scale all the components of a color from 0..1 (float) to 0..255 (integer)
  ### Examples
    iex> MyElixirRayTracer.Color.color_to_decimal(MyElixirRayTracer.Color.color(0, 0.5, 1))
    MyElixirRayTracer.Color.color(0, 128, 255)

  """
  def color_to_decimal(c) do
    color(scale_color_component(c.red), scale_color_component(c.green), scale_color_component(c.blue))
  end

  @doc """
  Two colors are "quite" equal (equal with tolerance)
  """
  def color_equal?(c1, c2) do
    equal(c1.red, c2.red) and equal(c1.green, c2.green) and equal(c1.blue, c2.blue)
  end

end
