defmodule MyElixirRayTracer.Canvas do
  @moduledoc """
  Canvas definition
  """
  alias MyElixirRayTracer.Canvas
  alias MyElixirRayTracer.Color

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
  def canvas(width, height, color \\ Color.color(0, 0, 0)) do
    row = List.duplicate(color, width)
    %Canvas{width: width, height: height, pixels: List.duplicate(row, height)}
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
    """ <> ppm_body(c.pixels)
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
  defp ppm_body(rows) do
    Enum.map_join(rows, "", &ppm_body_row/1)
  end

  defp ppm_body_row(pixels) do
    {last_line, ppm} =
      Enum.reduce(pixels, {"", ""}, fn pix, {line, ppm} ->
        scaled = Color.color_to_decimal(pix)
        token = "#{scaled.red} #{scaled.green} #{scaled.blue}"
        candidate = if line == "", do: token, else: line <> " " <> token
        if String.length(candidate) <= 70 do
          {candidate, ppm}
        else
          {token, ppm <> line <> "\n"}
        end
      end)
    ppm <> last_line <> "\n"
  end

end
