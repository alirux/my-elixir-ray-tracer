defmodule MyElixirRayTracer.Canvas do
  @moduledoc """
  Canvas definition
  """
  alias MyElixirRayTracer.Canvas

  import MyElixirRayTracer.Color
  # alias MyElixirRayTracer.Color

  defstruct width: 0, height: 0, pixels: [[]]

  @doc """
  Creates a canvas with all pixels set to the color specified
      0
      |
  0 --+--------------> x
      |
      |
      |
      |
      V
      y
  """
  def canvas(width, height, color \\ color(0, 0, 0)) do
    %Canvas { width: width, height: height, pixels: fill_matrix([], 0, height, width, color) }
  end

  @doc """
  Returns the color at x,y coordinates
  """
  def pixel_at(c, x, y) do
    Enum.at(Enum.at(c.pixels, y), x)
  end

  @doc """
  Write a pixel in the canvas x,y coord with the specified color
  """
  def write_pixel(c, x, y, color) do
    current_row = Enum.at(c.pixels, y)
    new_row = List.replace_at(current_row, x, color)
    new_cols = List.replace_at(c.pixels, y, new_row)
    %Canvas { width: c.width, height: c.height, pixels: new_cols }
  end

  @doc """
  Convert a canvas to PPM format ready to save
  """
  def canvas_to_ppm(c) do
    #flattened = List.flatten(c.pixels)
    """
    P3
    #{c.width} #{c.height}
    255
    """ <> ppm_body(c.pixels, "")
  end

  @doc """
  Save a convas to filename
  """
  def save_canvas(c, filename) do
    ppm = canvas_to_ppm(c)
    {:ok, file} = File.open(filename, [:write])
    IO.binwrite(file, ppm)
    File.close(file)
  end

  # Prints a PPM row after row
  defp ppm_body([row | others], ppm) do
    ppm_body(others, ppm <> ppm_body_row(row))
  end

  defp ppm_body([], ppm), do: ppm

  defp ppm_body_row(pixels), do: ppm_body_row(pixels, 0, "", false)

  # da due elementi
  defp ppm_body_row([pix | tail], count, ppm, add_space) do
    scaled_pix = color_to_decimal(pix)
    new_ppm_pix = "#{scaled_pix.red} #{scaled_pix.green} #{scaled_pix.blue}"
    new_ppm_pix_space = if add_space, do: " " <> new_ppm_pix, else: new_ppm_pix
    new_count = count + String.length(new_ppm_pix_space)
    cond do
      new_count <= 70 ->
        ppm_body_row(tail, new_count, ppm <> new_ppm_pix_space, true)
      new_count > 70 ->
        ppm_body_row(tail, String.length(new_ppm_pix), ppm <> "\n" <> new_ppm_pix, true)
    end

  end

  # nessun elemento
  defp ppm_body_row([], _, ppm, _), do: ppm <> "\n"

  defp fill_matrix(m, curr, height, width, color) when curr < height - 1 do
    fill_matrix([fill([], 0, width - 1, color)] ++ m, curr + 1, height, width, color)
  end

  defp fill_matrix(m, curr, height, width, color) when curr == height - 1 do
    [fill([], 0, width - 1, color)] ++ m
  end

  defp fill(lst, curr, max, color) when curr < max do
    fill([color] ++ lst, curr + 1, max, color)
  end

  defp fill(lst, curr, max, color) when curr == max do
    [color] ++ lst
  end

end
