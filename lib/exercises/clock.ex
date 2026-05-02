defmodule MyElixirRayTracer.Exercises.Clock do
  @moduledoc """
  Write e static clock on a canvas using transformations
  """
  alias MyElixirRayTracer.Canvas
  alias MyElixirRayTracer.Color
  alias MyElixirRayTracer.Matrix
  alias MyElixirRayTracer.Transformations

  @doc """
  Draw the clock on the x,y plane (z = 0)
  """
  def execute do
    c = Canvas.canvas(320, 320, Color.color(1, 1, 1))
    # Transformation for clock tick: 1/12 of the circle (2*pi)
    clock_trans = Matrix.identity_matrix4x4() |> Transformations.rotation_z(2 * :math.pi() / 12)
    # Transformation for the canvas: invert the y axis and translate (0,0) in the middle of the canvas (160,160)
    canvas_trans = Matrix.identity_matrix4x4() |> Transformations.scaling(1, -1, 1) |> Transformations.translation(160, 160, 0)
    # Starting tick_point on the clock at position 3
    tick_point = Matrix.mpoint(150, 0, 0)

    # Draw all 12 clock ticks
    {canvas, _} =
      Enum.reduce(0..11, {c, tick_point}, fn _i, {canvas, point} ->
        # Calculate the tick_point on the canvas coordinates
        {:ok, point_on_canvas} = Matrix.matrix_multiply(canvas_trans, point)
        cx = max(min(round(Matrix.at(point_on_canvas, 0, 0)), canvas.width - 1), 0)
        cy = max(min(round(Matrix.at(point_on_canvas, 1, 0)), canvas.height - 1), 0)
        new_canvas = Canvas.write_pixel(canvas, cx, cy, Color.color(0, 0, 0))
        # Calculate the next clock tick on the x,y native coordinates
        {:ok, new_point} = Matrix.matrix_multiply(clock_trans, point)
        {new_canvas, new_point}
      end)

    # Save the canvas
    Canvas.save_canvas(canvas, "/tmp/clock.ppm")
  end
end
