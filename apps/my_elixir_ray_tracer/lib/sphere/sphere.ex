defmodule MyElixirRayTracer.Sphere do

  alias MyElixirRayTracer.Matrix
  alias MyElixirRayTracer.Tuple, as: RTTuple
  alias MyElixirRayTracer.Material

  @doc """
  A sphere. inverse_transform and inverse_transpose_transform are pre-computed
  at construction time so they are not recomputed on every ray intersection.
  """
  defstruct [:radius, :transform, :inverse_transform, :inverse_transpose_transform, :material]

  defp build(transform, material) do
    {:ok, inv} = Matrix.matrix_inverse(transform)
    inv_t = Matrix.matrix_transpose(inv)
    %MyElixirRayTracer.Sphere{
      radius: 1,
      transform: transform,
      inverse_transform: inv,
      inverse_transpose_transform: inv_t,
      material: material
    }
  end

  def sphere(), do: build(Matrix.identity_matrix4x4(), Material.material())
  def sphere(transform), do: build(transform, Material.material())
  def sphere(transform, material), do: build(transform, material)

  def sphere_normal_at(sphere, world_point) do
    object_point = RTTuple.tuple_transform(sphere.inverse_transform, world_point)
    object_normal = RTTuple.minus(object_point, RTTuple.point(0, 0, 0))
    world_normal = RTTuple.tuple_transform(sphere.inverse_transpose_transform, object_normal)
    RTTuple.normalize %MyElixirRayTracer.Tuple{ world_normal | w: 0 }
  end

end
