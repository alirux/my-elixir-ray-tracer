defmodule MyElixirRayTracer.Material do

  import MyElixirRayTracer.Color

  @doc """
  A material
  """
  defstruct color: color(1, 1, 1), ambient: 0.1, diffuse: 0.9, specular: 0.9, shininess: 200.0

  @doc """
  A default material
  """
  def material() do
    %MyElixirRayTracer.Material {}
  end

  @doc """
  Build a material
  """
  def material(color, ambient, diffuse, specular, shininess) do
    %MyElixirRayTracer.Material { color: color, ambient: ambient, diffuse: diffuse, specular: specular, shininess: shininess }
  end


end
