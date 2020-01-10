defmodule MyElixirRayTracerTest.Color do
  use ExUnit.Case
  doctest MyElixirRayTracer.Color

  import MyElixirRayTracer.Color
  alias MyElixirRayTracer.Color

  import MyElixirRayTracer.Common

  test "Colors are (red, green, blue) tuples" do
    c = %Color { red: -0.5, green: 0.4, blue: 1.7 }
    assert c.red == -0.5
    assert c.green == 0.4
    assert c.blue == 1.7
  end

  test "Adding colors" do
    c1 = color(0.9, 0.6, 0.75)
    c2 = color(0.7, 0.1, 0.25)
    r = add(c1, c2)
    assert r.red == 0.9 + 0.7
    assert r.green == 0.6 + 0.1
    assert r.blue == 0.75 + 0.25
  end

  test "Subtracting colors" do
    c1 = color(0.9, 0.6, 0.75)
    c2 = color(0.7, 0.1, 0.25)
    r = minus(c1, c2)
    assert equal(r.red, 0.2)
    assert r.green == 0.5
    assert r.blue == 0.50
  end

  test "Multiplying a color by a scalar" do
    c = color(0.2, 0.3, 0.4)
    r = multiply(c, 2)
    assert r.red == 0.4
    assert r.green == 0.6
    assert r.blue == 0.8
  end

  test "Multiplying colors" do
    c1 = color(1, 0.2, 0.4)
    c2 = color(0.9, 1, 0.1)
    r = hadamard_prod(c1, c2)
    assert r.red == 0.9
    assert r.green == 0.2
    assert equal(r.blue, 0.04)
  end

end
