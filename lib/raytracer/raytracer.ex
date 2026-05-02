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
    IO.puts("Tracing #{@canvas_w}x#{@canvas_h} canvas on #{System.schedulers_online()} cores...")
    total_start = System.monotonic_time(:millisecond)

    # Compute pixel colors in parallel, one task per row
    canvas =
      half_h..-half_h//-1
      |> Task.async_stream(fn y ->
        row_start = System.monotonic_time(:millisecond)
        row_pixels =
          for x <- -half_w..half_w do
            ray_endpoint = RTTuple.point(x, y, @wall_z)
            ray = Ray.ray(eye_position, RTTuple.normalize(RTTuple.minus(ray_endpoint, eye_position)))
            trace_pixel(ray, ray_endpoint, canvas_trans, s, light)
          end
        IO.puts("Row #{y} — #{System.monotonic_time(:millisecond) - row_start}ms [#{inspect(self())}]")
        row_pixels
      end, ordered: true)
      |> Enum.flat_map(fn {:ok, row} -> row end)
      |> Enum.reduce(canvas, fn
        nil, acc -> acc
        {cx, cy, color}, acc -> Canvas.write_pixel(acc, cx, cy, color)
      end)

    total_ms = System.monotonic_time(:millisecond) - total_start
    IO.puts("Done in #{total_ms}ms (#{Float.round(total_ms / (@canvas_w * @canvas_h) * 1000, 2)}µs/pixel). Saving to /tmp/sphere.ppm")
    Canvas.save_canvas(canvas, "/tmp/sphere.ppm")
  end

  defp find_hit(ray, sphere) do
    # Find the intersections, extract only the values from the map, then find hits
    Ray.ray_intersect(sphere, ray) |> Map.values() |> Intersection.hit()
  end

  # Compute the color of a single pixel; returns {cx, cy, color} or nil on no hit
  defp trace_pixel(ray, ray_endpoint, canvas_trans, sphere, light) do
    case find_hit(ray, sphere) do
      nil ->
        nil
      hit ->
        # Transform the world coordinate ray_endpoint into canvas coordinates
        ray_endpoint_canvas = RTTuple.tuple_transform(canvas_trans, ray_endpoint)
        cx = max(min(round(ray_endpoint_canvas.x), @canvas_w - 1), 0)
        cy = max(min(round(ray_endpoint_canvas.y), @canvas_h - 1), 0)

        # Find the color of the point with the Phong model
        point = Ray.ray_position(ray, hit.time)
        normal = Sphere.sphere_normal_at(hit.object, point)
        eye = RTTuple.negate(ray.direction)
        color = Material.lighting(hit.object.material, light, point, eye, normal)

        {cx, cy, color}
    end
  end


end
