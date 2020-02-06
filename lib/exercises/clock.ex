defmodule MyElixirRayTracer.Exercises.Clock do
  @moduledoc """
  Write e static clock on a canvas using transformations
  """
  import MyElixirRayTracer.Canvas
  import MyElixirRayTracer.Color
  import MyElixirRayTracer.Matrix
  import MyElixirRayTracer.Transformations

  def write_clock_tick(c, p, pc, t, tc, i) when i < 12 do
    # Print the point on the canvas. No manual translation is required (it is done by the tc transformation)
    # Just be sure to don't exceed the canvas size
    # Use the point on the canvas pc
    cx = max(min(round(pc[0.0]), c.width - 1), 0)
    cy = max(min(round(pc[1.0]), c.height - 1), 0)
    #Mix.Shell.IO.info("#{i}: #{p[0.0]},#{p[1.0]} #{cx},#{cy}")
    # Write the pixel
    new_c = write_pixel(c, cx, cy, color(0, 0, 0))

    # Calculate the new clock tick on the x,y native coordinates
    { :ok, new_p } = matrix_multiply(t, p);
    # Calculate the new clock tick on the canvas coordinates
    { :ok, new_pc } = matrix_multiply(tc, new_p);
    # Print the new point and do the next loop (i+1)
    write_clock_tick(new_c, new_p, new_pc, t, tc, i + 1);
  end
  def write_clock_tick(c, _p, _pc, _t, _tc, 12) do
    c
  end

  @doc """
  Draw the clock on the x,y plane (z = 0)
  """
  def execute do
    c = canvas(320, 320, color(1, 1, 1))
    # Transformation for clock tick: 1/12 of the circle (2*pi)
    t = identity_matrix4x4() |> rotation_z(2 * :math.pi() / 12)
    # Transforrmation for the canvas: invert the y axis and translate (0,0) in the middle of the canvas (160,160)
    tc = identity_matrix4x4() |> scaling(1, -1, 1) |> translation(160, 160, 0)
    # Starting point
    p = mpoint(150, 0, 0)
    # Starting point on the canvas
    { :ok, pc } = matrix_multiply(tc, p)
    # Start to print the clock ticks
    c = write_clock_tick(c, p, pc, t, tc, 0)
    # Save the canvas
    save_canvas(c, "/tmp/clock.ppm")
  end
end
