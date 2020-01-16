defmodule MyElixirRayTracerTest.Canvas do
  use ExUnit.Case
  doctest(MyElixirRayTracer.Canvas)

  import MyElixirRayTracer.Canvas
  #alias MyElixirRayTracer.Canvas

  import MyElixirRayTracer.Color
  #alias MyElixirRayTracer.Color

  test "Creating a canvas" do
    c = canvas(100, 200)
    # Correct pixels height (rows)
    assert length(c.pixels) == 200
    # Correct pixels width (cols)
    assert length(Enum.at(c.pixels, 0)) == 100
    assert length(Enum.at(c.pixels, 50)) == 100
    assert length(Enum.at(c.pixels, 99)) == 100
    # All pixels are set to zero
    for x <- 0..99 do
      for y <- 0..199 do
        assert pixel_at(c, x, y) == color(0, 0, 0)
      end
    end
  end

  test "Writing pixels to a canvas" do
    c = canvas(10, 20)
    red = color(1, 0, 0)
    new_canvas = write_pixel(c, 2, 3, red)
    assert pixel_at(new_canvas, 2, 3) == red
    assert length(c.pixels) == 20
    assert length(Enum.at(c.pixels, 3)) == 10
    assert pixel_at(new_canvas, 0, 0) == color(0, 0, 0)
    assert pixel_at(new_canvas, 1, 3) == color(0, 0, 0)
    assert pixel_at(new_canvas, 2, 4) == color(0, 0, 0)
  end

  test "Constructing the PPM header" do
    c = canvas(1, 1)
    ppm = canvas_to_ppm(c)
    assert ppm == """
    P3
    1 1
    255
    0 0 0
    """
  end

  test "Constructing the PPM pixel data" do
    c = canvas(5, 3)
    c1 = color(1.5, 0, 0)
    c2 = color(0, 0.5, 0)
    c3 = color(-0.5, 0, 1)
    c = write_pixel(c, 0, 0, c1)
    c = write_pixel(c, 2, 1, c2)
    c = write_pixel(c, 4, 2, c3)
    ppm = canvas_to_ppm(c)
    assert ppm == """
    P3
    5 3
    255
    255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 128 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 255
    """
  end

  test "Splitting long lines in PPM files" do
    c = canvas(11, 2, color(1, 0.8, 0.6))
    ppm = canvas_to_ppm(c)
    assert ppm == """
    P3
    11 2
    255
    255 204 153 255 204 153 255 204 153 255 204 153 255 204 153
    255 204 153 255 204 153 255 204 153 255 204 153 255 204 153
    255 204 153
    255 204 153 255 204 153 255 204 153 255 204 153 255 204 153
    255 204 153 255 204 153 255 204 153 255 204 153 255 204 153
    255 204 153
    """
  end

  # test "big ppm" do
  #   c = canvas(4000, 4000)
  #   ppm = canvas_to_ppm(c)
  #   {:ok, file} = File.open("/tmp/test.ppm", [:write])
  #   IO.binwrite(file, ppm)
  #   File.close(file)
  # end

end
