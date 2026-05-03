defmodule MyElixirRayTracer.Intersection do

  defstruct [ :time, :object ]

  def intersection(time, object) do
    %MyElixirRayTracer.Intersection {time: time, object: object}
  end

  @doc """
  Add a new intersection to a list of intersections maintaining the time order (asc)
  """
  def intersections_add(old_intersections, new_intersection) when is_list(old_intersections) and is_struct(new_intersection, MyElixirRayTracer.Intersection) do
    [new_intersection | old_intersections] |> Enum.sort(&(&1.time < &2.time))
  end

  @doc """
  Build a list of two intersections ordered by the time (asc)
  """
  def intersections(i1, i2) when is_struct(i1, MyElixirRayTracer.Intersection) and is_struct(i2, MyElixirRayTracer.Intersection) do
    [i1 | [i2 | []]] |> Enum.sort(&(&1.time < &2.time))
    #intersections([], i1) |> intersections(i2)
  end

  @doc """
  Find the first non negative intersection: a hit between the ray and an object
  """
  def hit(intersections) do
    #List.first(intersections)
    Enum.find(intersections, &(&1.time >= 0))
  end

end
