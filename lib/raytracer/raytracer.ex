defmodule MyElixirRayTracer.Raytracer do

  import MyElixirRayTracer.Canvas
  import MyElixirRayTracer.Color, only: [color: 3]
  import MyElixirRayTracer.Tuple
  import MyElixirRayTracer.Sphere
  import MyElixirRayTracer.Matrix
  import MyElixirRayTracer.Transformations
  import MyElixirRayTracer.Ray
  import MyElixirRayTracer.Intersection
  import MyElixirRayTracer.Material
  import MyElixirRayTracer.PointLight

  @wall_z   0 # z of the wall on which the sphere is projected
  @canvas_w 300 # width of the canvas
  @canvas_h 300 # height of the canvas

  def trace() do
    # Canvas
    canvas = canvas(@canvas_w, @canvas_h, color(0, 0, 0))
    # Transforrmation for the canvas: invert the y axis and translate (0,0) in the middle of the canvas
    canvas_trans = identity_matrix4x4() |> scaling(1, -1, 1) |> translation(@canvas_w/2, @canvas_h/2, 0)

    # Eye configuration
    eye_position = point(0, 0, -400)

    # Sphere and material
    sphere_trans = identity_matrix4x4() |> scaling(@canvas_w / 3, @canvas_w / 3, @canvas_w / 3)
    material = material(color(1, 0.2, 1), 0.1, 0.9, 0.9, 100)
    s = sphere(sphere_trans, material)

    # Light configuration
    light_position = point(-400, 400, -400)
    light_color = color(1, 1, 1)
    light = point_light(light_position, light_color)

    # Start the ray tracing
    scan(-canvas.width / 2, canvas.height / 2, eye_position, canvas, canvas_trans, s, light)
    |> save_canvas("/tmp/sphere.ppm")
  end

  defp scan(x, y, eye_position, canvas, canvas_trans, sphere, light) do
    ray_endpoint = point(x, y, @wall_z)
    ray = ray(eye_position, normalize(minus(ray_endpoint, eye_position)))
    canvas = find_hit(ray, sphere) |> draw_hit_point(ray, ray_endpoint, canvas, canvas_trans, light)
    #Mix.Shell.IO.info("#{x},#{y}")
    cond do
      # Current row (y), scan the next column (x)
      x < canvas.width / 2 and y > -canvas.height / 2 -> scan(x+1, y, eye_position, canvas, canvas_trans, sphere, light)
      # End of the current row, scan the next next row
      x >= canvas.width / 2 and y > -canvas.height / 2 -> Mix.Shell.IO.info("Row #{y}"); scan(-canvas.width / 2, y-1, eye_position, canvas, canvas_trans, sphere, light)
      # End of the job, return the canvas
      x == -canvas.width / 2 and y <= -canvas.height / 2 -> canvas
    end
  end

  defp find_hit(ray, sphere) do
    # Find the intersections, extract only the values from the map, then find hits
    ray_intersect(sphere, ray) |> Map.values() |> hit()
  end

  # No hits, return the untouched canvas
  defp draw_hit_point(nil, _ray, _ray_enpoint, canvas, _canvas_trans, _light) do
    canvas
  end

  # hit found, draw it on the canvas
  defp draw_hit_point(hit, ray, ray_enpoint, canvas, canvas_trans, light) do
    # transform the world coordinate ray_endpoint in canvas coordinates with canvas_trans
    ray_enpoint_canvas = tuple_transform(canvas_trans, ray_enpoint)
    cx = max(min(round(ray_enpoint_canvas.x), canvas.width - 1), 0)
    cy = max(min(round(ray_enpoint_canvas.y), canvas.height - 1), 0)
    #IO.inspect(hit_position)
    #IO.inspect(ray_enpoint_canvas)
    #Mix.Shell.IO.info("rep=(#{ray_enpoint.x},#{ray_enpoint.y}) repc=(#{ray_enpoint_canvas.x},#{ray_enpoint_canvas.y}) c=(#{cx},#{cy})")

    # Find the color of the point with the Phong model
    point = ray_position(ray, hit.time)
    normal = sphere_normal_at(hit.object, point)
    eye = negate(ray.direction)
    color = lighting(hit.object.material, light, point, eye, normal)
    #IO.inspect(normal)
    #Mix.Shell.IO.info("point=(#{point.x},#{point.y}) hit.time=#{hit.time} color=(#{color.red},#{color.green},#{color.blue}) c=(#{cx},#{cy})")

    write_pixel(canvas, cx, cy, color)
  end


end
