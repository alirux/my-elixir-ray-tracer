defmodule MyElixirRayTracer.Common do

  @spec equal(number, number) :: boolean
  def equal(a, b) do
    if abs(a - b) <= 0.00001 do
      true
    else
      false
    end
  end

end
