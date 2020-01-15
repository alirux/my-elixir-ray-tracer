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
  """
  def canvas(width, height, color \\ color(0, 0, 0)) do
    %Canvas { width: width, height: height, pixels: fill_matrix([], 0, height, width, color) }
  end

  def pixel_at(c, x, y) do
    Enum.at(Enum.at(c.pixels, y), x)
  end

  def write_pixel(c, x, y, color) do
    current_row = Enum.at(c.pixels, y)
    new_row = List.replace_at(current_row, x, color)
    new_cols = List.replace_at(c.pixels, y, new_row)
    %Canvas { width: c.width, height: c.height, pixels: new_cols }
  end

  def canvas_to_bpm(c) do
    #flattened = List.flatten(c.pixels)
    """
    P3
    #{c.width} #{c.height}
    255
    """ <> bpm_body(c.pixels, "")
  end

  # Prints a row after row
  defp bpm_body([row | others], bpm) do
    bpm_body(others, bpm <> bpm_body_row(row))
  end

  defp bpm_body([], bpm), do: bpm

  defp bpm_body_row(pixels), do: bpm_body_row(pixels, 0, "", false)

  # da due elementi
  defp bpm_body_row([pix | tail], count, bpm, add_space) do
    scaled_pix = color_to_decimal(pix)
    new_bpm_pix = "#{scaled_pix.red} #{scaled_pix.green} #{scaled_pix.blue}"
    new_bpm_pix_space = if add_space, do: " " <> new_bpm_pix, else: new_bpm_pix
    new_count = count + String.length(new_bpm_pix_space)
    cond do
      new_count <= 70 ->
        bpm_body_row(tail, new_count, bpm <> new_bpm_pix_space, true)
      new_count > 70 ->
        bpm_body_row(tail, String.length(new_bpm_pix), bpm <> "\n" <> new_bpm_pix, true)
    end

  end

  # nessun elemento
  defp bpm_body_row([], _, bpm, _), do: bpm <> "\n"

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
