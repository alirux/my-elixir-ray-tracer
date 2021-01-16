defmodule MyElixirRayTracer.Sphere do

  import MyElixirRayTracer.Matrix
  import MyElixirRayTracer.Tuple

  defstruct radius: 1, transform: identity_matrix4x4()

  def sphere() do
    %MyElixirRayTracer.Sphere {}
  end

  def sphere(transform) do
    %MyElixirRayTracer.Sphere { transform: transform }
  end

  @doc """
  Finf the normal on a sphere at the point specified
  """
  def sphere_normal_at(sphere, world_point) do
    #IO.inspect(world_point)
    object_point = sphere.transform |> matrix_inverse!() |> tuple_transform(world_point)
    #IO.inspect(object_point)
    object_normal = minus(object_point, point(0, 0, 0))
    #IO.inspect(object_normal)
    world_normal = sphere.transform |> matrix_inverse!() |> matrix_transpose() |> tuple_transform(object_normal)
    #IO.inspect(world_normal)
    #IO.inspect(magnitude(world_normal))
    normalize %MyElixirRayTracer.Tuple{ world_normal | w: 0 }
  end

end
