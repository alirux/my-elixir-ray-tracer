defmodule MyElixirRayTracer.Material do

  import MyElixirRayTracer.Color
  import MyElixirRayTracer.Tuple

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

  @doc """
  Phong reflection model
  """
  def lighting(material, light, position, eyev, normalv) do
    effective_color = hadamard_prod(material.color, light.intensity)
    lightv = normalize(minus(light.position, position))
    ambient = color_multiply(effective_color, material.ambient)

    light_dot_normal = dot(lightv, normalv)
    if light_dot_normal < 0 do
      diffuse = color(0, 0, 0)
      specular = color(0, 0, 0)
      color_add(ambient, diffuse) |> color_add(specular)
    else
      diffuse = color_multiply(effective_color, material.diffuse * light_dot_normal)
      reflectv = reflect(negate(lightv), normalv)
      reflect_dot_eye = dot(reflectv, eyev)
      if reflect_dot_eye <= 0 do
        specular = color(0, 0, 0)
        color_add(ambient, diffuse) |> color_add(specular)
      else
        factor = :math.pow(reflect_dot_eye, material.shininess)
        specular = color_multiply(light.intensity, material.specular * factor)
        color_add(ambient, diffuse) |> color_add(specular)
      end
    end
  end


end
