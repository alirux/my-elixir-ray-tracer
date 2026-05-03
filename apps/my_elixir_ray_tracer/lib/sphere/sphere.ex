defmodule MyElixirRayTracer.Sphere do

  alias MyElixirRayTracer.Matrix
  alias MyElixirRayTracer.Tuple, as: RTTuple
  alias MyElixirRayTracer.Material

  @doc """
  A sphere
  """
  defstruct radius: 1, transform: Matrix.identity_matrix4x4(), material: Material.material()

  @doc """
  Build a default sphere
  """
  def sphere() do
    %MyElixirRayTracer.Sphere {}
  end

  @doc """
  Build a sphere with a specific transform
  """
  def sphere(transform) do
    %MyElixirRayTracer.Sphere { transform: transform }
  end

  @doc """
  Build a sphere with a specific transform and material
  """
  def sphere(transform, material) do
    %MyElixirRayTracer.Sphere { transform: transform, material: material }
  end

  @doc """
  Find the normal on a sphere at the point specified
  """
  def sphere_normal_at(sphere, world_point) do
    #IO.inspect(world_point)
    object_point = sphere.transform |> Matrix.matrix_inverse!() |> RTTuple.tuple_transform(world_point)
    #IO.inspect(object_point)
    object_normal = RTTuple.minus(object_point, RTTuple.point(0, 0, 0))
    #IO.inspect(object_normal)
    world_normal = sphere.transform |> Matrix.matrix_inverse!() |> Matrix.matrix_transpose() |> RTTuple.tuple_transform(object_normal)
    #IO.inspect(world_normal)
    #IO.inspect(magnitude(world_normal))
    RTTuple.normalize %MyElixirRayTracer.Tuple{ world_normal | w: 0 }
  end

end
