defmodule MyElixirRayTracer.Sphere do

  import MyElixirRayTracer.Matrix
  import MyElixirRayTracer.Transformations

  defstruct radius: 1, transform: identity_matrix4x4()

  def sphere() do
    %MyElixirRayTracer.Sphere {}
  end

  def sphere(transform) do
    %MyElixirRayTracer.Sphere { transform: transform }
  end

end
