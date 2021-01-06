defmodule MyElixirRayTracer.Exercises.Clock do
  @moduledoc """
  Write e static clock on a canvas using transformations
  """
  import MyElixirRayTracer.Canvas
  import MyElixirRayTracer.Color
  import MyElixirRayTracer.Matrix
  import MyElixirRayTracer.Transformations

  def write_clock_tick(canvas, tick_point, tick_point_on_canvas, clock_trans, canvas_trans, iteration) when iteration < 12 do
    # Print the tick_point on the canvas. No manual translation is required (it is done by the canvas_trans transformation)
    # Just be sure to don't exceed the canvas size
    # Use the tick_point on the canvas tick_point_on_canvas
    cx = max(min(round(tick_point_on_canvas[0.0]), canvas.width - 1), 0)
    cy = max(min(round(tick_point_on_canvas[1.0]), canvas.height - 1), 0)
    #Mix.Shell.IO.info("#{i}: #{tick_point[0.0]},#{tick_point[1.0]} #{cx},#{cy}")
    # Write the pixel
    new_canvas = write_pixel(canvas, cx, cy, color(0, 0, 0))

    # Calculate the new clock tick on the x,y native coordinates
    { :ok, new_tick_point } = matrix_multiply(clock_trans, tick_point);
    # Calculate the new clock tick on the canvas coordinates
    { :ok, new_tick_point_on_canvas } = matrix_multiply(canvas_trans, new_tick_point);
    # Print the new tick_point and do the next loop (i+1)
    write_clock_tick(new_canvas, new_tick_point, new_tick_point_on_canvas, clock_trans, canvas_trans, iteration + 1);
  end
  def write_clock_tick(canvas, _point, _point_on_canvas, _clock_trans, _canvas_trans, 12) do
    canvas
  end

  @doc """
  Draw the clock on the x,y plane (z = 0)
  """
  def execute do
    c = canvas(320, 320, color(1, 1, 1))
    # Transformation for clock tick: 1/12 of the circle (2*pi)
    clock_trans = identity_matrix4x4() |> rotation_z(2 * :math.pi() / 12)
    # Transforrmation for the canvas: invert the y axis and translate (0,0) in the middle of the canvas (160,160)
    canvas_trans = identity_matrix4x4() |> scaling(1, -1, 1) |> translation(160, 160, 0)
    # Starting tick_point on the clock at position 3
    tick_point = mpoint(150, 0, 0)
    # Starting tick_point on the canvas
    { :ok, tick_point_on_canvas } = matrix_multiply(canvas_trans, tick_point)
    # Start to print the clock ticks
    c = write_clock_tick(c, tick_point, tick_point_on_canvas, clock_trans, canvas_trans, 0)
    # Save the canvas
    save_canvas(c, "/tmp/clock.ppm")
  end
end
