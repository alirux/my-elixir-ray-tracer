defmodule MyElixirRayTracer.Intersection do

  defstruct [ :time, :object ]

  def intersection(time, object) do
    %MyElixirRayTracer.Intersection {time: time, object: object}
  end

  def intersections(old_intersections, new_intersection) when is_list(old_intersections) and is_struct(new_intersection, MyElixirRayTracer.Intersection) do
    [new_intersection | old_intersections] |> Enum.sort(&(&1.time < &2.time))
  end

  def intersections(i1, i2) when is_struct(i1, MyElixirRayTracer.Intersection) and is_struct(i2, MyElixirRayTracer.Intersection) do
    [i1 | [i2 | []]] |> Enum.sort(&(&1.time < &2.time))
    #intersections([], i1) |> intersections(i2)
  end

  def hit(intersections) do
    #List.first(intersections)
    Enum.find(intersections, &(&1.time >= 0))
  end

end
