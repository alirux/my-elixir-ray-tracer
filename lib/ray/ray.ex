defmodule MyElixirRayTracer.Ray do

  alias MyElixirRayTracer.Ray

  import MyElixirRayTracer.Tuple
  import MyElixirRayTracer.Intersection
  import MyElixirRayTracer.Matrix

  defstruct [ :origin, :direction ]

  def ray(origin, direction) do
    %Ray { origin: origin, direction: direction }
  end

  @doc """
  Find the point at distance t from origin of the ray along its direction
  """
  def ray_position(ray, t) do
    #plus(ray.origin, multiply(ray.direction, t)
    ray.direction |> multiply(t) |> plus(ray.origin)
  end

  @doc """
  Find the intersections between a ray and a sphere.
  They can be zero (no intersections), two with the same value (tangent) or two distinct values.
  The result of the function is a map with integer keys (0, 1) and intersection struct as values.
  """
  def ray_intersect(sphere, ray) do
    # Find the inverse sphere transformation and apply it to the ray
    { :ok, sphere_inv_trans } = matrix_inverse(sphere.transform)
    ray = ray_transform(ray, sphere_inv_trans)
    # Calculate the intersections
    sphere_center_to_ray_origin_vector = minus(ray.origin, point(0, 0, 0))
    a = dot(ray.direction, ray.direction)
    b = 2 * dot(ray.direction, sphere_center_to_ray_origin_vector)
    c = dot(sphere_center_to_ray_origin_vector, sphere_center_to_ray_origin_vector) - 1
    discriminant = b * b - 4 * a * c;
    if discriminant < 0 do
      %{}
    else
      determinant_sqrt = :math.sqrt(discriminant)
      t1 = ( - b - determinant_sqrt) / ( 2 * a )
      t2 = ( - b + determinant_sqrt) / ( 2 * a )
      %{ 0 => intersection(t1, sphere), 1 => intersection(t2, sphere) }
    end
  end

  @doc """
  Transform the ray (translation, scling, ...) by applying the transformation matrix to the origin and direction
  """
  def ray_transform(ray, trans_matrix) do
    ray(tuple_transform(ray.origin, trans_matrix), tuple_transform(ray.direction, trans_matrix))
  end

end
