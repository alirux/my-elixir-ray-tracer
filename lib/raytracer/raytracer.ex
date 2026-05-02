defmodule MyElixirRayTracer.Raytracer do

  alias MyElixirRayTracer.Canvas
  alias MyElixirRayTracer.Color
  alias MyElixirRayTracer.Tuple, as: RTTuple
  alias MyElixirRayTracer.Sphere
  alias MyElixirRayTracer.Matrix
  alias MyElixirRayTracer.Transformations
  alias MyElixirRayTracer.Ray
  alias MyElixirRayTracer.Intersection
  alias MyElixirRayTracer.Material
  alias MyElixirRayTracer.PointLight

  @wall_z   0 # z of the wall on which the sphere is projected
  @canvas_w 300 # width of the canvas
  @canvas_h 300 # height of the canvas

  def trace() do
    # Canvas
    canvas = Canvas.canvas(@canvas_w, @canvas_h, Color.color(0, 0, 0))
    # Transformation for the canvas: invert the y axis and translate (0,0) in the middle of the canvas
    canvas_trans = Matrix.identity_matrix4x4() |> Transformations.scaling(1, -1, 1) |> Transformations.translation(@canvas_w / 2, @canvas_h / 2, 0)

    # Eye configuration
    eye_position = RTTuple.point(0, 0, -400)

    # Sphere and material
    sphere_trans = Matrix.identity_matrix4x4() |> Transformations.scaling(@canvas_w / 3, @canvas_w / 3, @canvas_w / 3)
    material = Material.material(Color.color(1, 0.2, 1), 0.1, 0.9, 0.9, 100)
    s = Sphere.sphere(sphere_trans, material)

    # Light configuration
    light_position = RTTuple.point(-400, 400, -400)
    light_color = Color.color(1, 1, 1)
    light = PointLight.point_light(light_position, light_color)

    # Start the ray tracing
    half_w = trunc(@canvas_w / 2)
    half_h = trunc(@canvas_h / 2)
    IO.puts("Tracing #{@canvas_w}x#{@canvas_h} canvas...")
    total_start = System.monotonic_time(:millisecond)

    {canvas, _} =
      for y <- half_h..-half_h//-1, x <- -half_w..half_w, reduce: {canvas, total_start} do
        {acc, row_start} ->
          new_row_start = if x == -half_w do
            now = System.monotonic_time(:millisecond)
            if y == half_h do
              IO.puts("Row #{y} — total #{now - total_start}ms")
            else
              IO.puts("Row #{y} — #{now - row_start}ms row, #{now - total_start}ms total")
            end
            now
          else
            row_start
          end
          ray_endpoint = RTTuple.point(x, y, @wall_z)
          ray = Ray.ray(eye_position, RTTuple.normalize(RTTuple.minus(ray_endpoint, eye_position)))
          new_canvas = find_hit(ray, s) |> draw_hit_point(ray, ray_endpoint, acc, canvas_trans, light)
          {new_canvas, new_row_start}
      end

    total_ms = System.monotonic_time(:millisecond) - total_start
    IO.puts("Done in #{total_ms}ms (#{Float.round(total_ms / (@canvas_w * @canvas_h) * 1000, 2)}µs/pixel). Saving to /tmp/sphere.ppm")
    Canvas.save_canvas(canvas, "/tmp/sphere.ppm")
  end

  defp find_hit(ray, sphere) do
    # Find the intersections, extract only the values from the map, then find hits
    Ray.ray_intersect(sphere, ray) |> Map.values() |> Intersection.hit()
  end

  # No hits, return the untouched canvas
  defp draw_hit_point(nil, _ray, _ray_enpoint, canvas, _canvas_trans, _light) do
    canvas
  end

  # hit found, draw it on the canvas
  defp draw_hit_point(hit, ray, ray_enpoint, canvas, canvas_trans, light) do
    # transform the world coordinate ray_endpoint in canvas coordinates with canvas_trans
    ray_enpoint_canvas = RTTuple.tuple_transform(canvas_trans, ray_enpoint)
    cx = max(min(round(ray_enpoint_canvas.x), canvas.width - 1), 0)
    cy = max(min(round(ray_enpoint_canvas.y), canvas.height - 1), 0)
    #IO.inspect(hit_position)
    #IO.inspect(ray_enpoint_canvas)
    #Mix.Shell.IO.info("rep=(#{ray_enpoint.x},#{ray_enpoint.y}) repc=(#{ray_enpoint_canvas.x},#{ray_enpoint_canvas.y}) c=(#{cx},#{cy})")

    # Find the color of the point with the Phong model
    point = Ray.ray_position(ray, hit.time)
    normal = Sphere.sphere_normal_at(hit.object, point)
    eye = RTTuple.negate(ray.direction)
    color = Material.lighting(hit.object.material, light, point, eye, normal)
    #IO.inspect(normal)
    #Mix.Shell.IO.info("point=(#{point.x},#{point.y}) hit.time=#{hit.time} color=(#{color.red},#{color.green},#{color.blue}) c=(#{cx},#{cy})")

    Canvas.write_pixel(canvas, cx, cy, color)
  end


end
