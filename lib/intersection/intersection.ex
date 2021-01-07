defmodule MyElixirRayTracer.Intersection do

  defstruct [ :time, :object ]

  def intersection(time, object) do
    %MyElixirRayTracer.Intersection {time: time, object: object}
  end

end
