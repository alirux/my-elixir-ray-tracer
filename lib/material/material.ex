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
  Find the color of the position with the Phong reflection model

  https://en.wikipedia.org/wiki/Phong_reflection_model
  """
  def lighting(material, light, position, eyev, normalv) do
    # The resulting color at the position
    effective_color = hadamard_prod(material.color, light.intensity)

    # The light vector of the Phong model
    lightv = normalize(minus(light.position, position))

    # Ambient color at the position
    ambient = color_multiply(effective_color, material.ambient)

    # Based on the Phong formula, to calculate the diffuse color, we need the dot product of the light and normal vectors
    # lightv and normalv are normalized, so the dot product is the cosine of the angle
    # effective_color * Kd(LN)
    # L=lightv, N=normalv
    light_dot_normal = dot(lightv, normalv)
    if light_dot_normal < 0 do
      # The light is not "visibile", so diffuse and specular are black at the position
      diffuse = color(0, 0, 0)
      specular = color(0, 0, 0)
      #Mix.Shell.IO.info("1")
      color_add(ambient, diffuse) |> color_add(specular)
    else
      # The light is visible
      # Diffuse component: effective_color * Kd(LN)
      diffuse = color_multiply(effective_color, material.diffuse * light_dot_normal)

      # Specular component: lightIntensity * Ks(RE)^materialShininess
      # R=reflectv, E=eyev
      reflectv = reflect(negate(lightv), normalv)
      reflect_dot_eye = dot(reflectv, eyev)
      if reflect_dot_eye <= 0 do
        # No reflection so specular is black
        specular = color(0, 0, 0)
        #Mix.Shell.IO.info("2")
        color_add(ambient, diffuse) |> color_add(specular)
      else
        # factor = (RE)^materialShininess
        # specular = lightIntensity * Ks * factor
        factor = :math.pow(reflect_dot_eye, material.shininess)
        specular = color_multiply(light.intensity, material.specular * factor)
        #Mix.Shell.IO.info("3")
        color_add(ambient, diffuse) |> color_add(specular)
      end
    end
  end


end
