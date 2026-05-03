defmodule MyElixirRayTracer.Material do

  alias MyElixirRayTracer.Color
  alias MyElixirRayTracer.Tuple, as: RTTuple

  @doc """
  A material
  """
  defstruct color: Color.color(1, 1, 1), ambient: 0.1, diffuse: 0.9, specular: 0.9, shininess: 200.0

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
    effective_color = Color.hadamard_prod(material.color, light.intensity)

    # The light vector of the Phong model
    lightv = RTTuple.normalize(RTTuple.minus(light.position, position))

    # Ambient color at the position
    ambient = Color.color_multiply(effective_color, material.ambient)

    # Based on the Phong formula, to calculate the diffuse color, we need the dot product of the light and normal vectors
    # lightv and normalv are normalized, so the dot product is the cosine of the angle
    # effective_color * Kd(LN)
    # L=lightv, N=normalv
    light_dot_normal = RTTuple.dot(lightv, normalv)
    if light_dot_normal < 0 do
      # The light is not "visibile", so diffuse and specular are black at the position
      diffuse = Color.color(0, 0, 0)
      specular = Color.color(0, 0, 0)
      #Mix.Shell.IO.info("1")
      Color.color_add(ambient, diffuse) |> Color.color_add(specular)
    else
      # The light is visible
      # Diffuse component: effective_color * Kd(LN)
      diffuse = Color.color_multiply(effective_color, material.diffuse * light_dot_normal)

      # Specular component: lightIntensity * Ks(RE)^materialShininess
      # R=reflectv, E=eyev
      reflectv = RTTuple.reflect(RTTuple.negate(lightv), normalv)
      reflect_dot_eye = RTTuple.dot(reflectv, eyev)
      if reflect_dot_eye <= 0 do
        # No reflection so specular is black
        specular = Color.color(0, 0, 0)
        #Mix.Shell.IO.info("2")
        Color.color_add(ambient, diffuse) |> Color.color_add(specular)
      else
        # factor = (RE)^materialShininess
        # specular = lightIntensity * Ks * factor
        factor = :math.pow(reflect_dot_eye, material.shininess)
        specular = Color.color_multiply(light.intensity, material.specular * factor)
        #Mix.Shell.IO.info("3")
        Color.color_add(ambient, diffuse) |> Color.color_add(specular)
      end
    end
  end


end
