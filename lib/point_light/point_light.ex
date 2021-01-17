defmodule MyElixirRayTracer.PointLight do

  @doc """
  A punctiform light source has a position and a color (intensity)
  """
  defstruct position: nil, intensity: nil

  @doc """
  Build a light source
  """
  def point_light(position, intensity) do
    %MyElixirRayTracer.PointLight { position: position, intensity: intensity }
  end


end
