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

  @wall_z 0 # z of the wall on which the sphere is projected

  def trace(canvas_w \\ 300, canvas_h \\ 300) do
    scene = build_scene(canvas_w, canvas_h,
      Material.material(Color.color(1, 0.2, 1), 0.1, 0.9, 0.9, 100),
      PointLight.point_light(RTTuple.point(-400, 400, -400), Color.color(1, 1, 1)),
      RTTuple.point(0, 0, -400),
      100
    )

    canvas =
      render_rows(scene, canvas_w, canvas_h, ordered: true)
      |> Enum.flat_map(fn {:ok, {_y, row_pixels}} -> row_pixels end)
      |> Enum.reduce(Canvas.canvas(canvas_w, canvas_h, Color.color(0, 0, 0)), fn
        nil, acc -> acc
        {cx, cy, color}, acc -> Canvas.write_pixel(acc, cx, cy, color)
      end)

    log_done(canvas_w, canvas_h, scene.total_start, "Saving to /tmp/sphere.ppm")
    Canvas.save_canvas(canvas, "/tmp/sphere.ppm")
  end

  @doc """
  Stream the ray tracing results to a browser via Phoenix.PubSub.
  Broadcasts {:row_ready, %{y: cy, pixels: [[x,r,g,b],...]}} per row (unordered)
  and {:trace_done, %{ms: total_ms}} when finished.
  """
  def trace_streaming(topic, pubsub_server, canvas_w \\ 300, canvas_h \\ 300,
        material \\ Material.material(Color.color(1, 0.2, 1), 0.1, 0.9, 0.9, 100),
        light \\ PointLight.point_light(RTTuple.point(-400, 400, -400), Color.color(1, 1, 1)),
        eye_position \\ RTTuple.point(0, 0, -400),
        sphere_r \\ 100) do
    scene = build_scene(canvas_w, canvas_h, material, light, eye_position, sphere_r)

    render_rows(scene, canvas_w, canvas_h, ordered: false)
    |> Stream.each(fn {:ok, {y, row_pixels}} ->
      # Canvas y for this world row
      cy = max(min(round(canvas_h / 2 - y), canvas_h - 1), 0)

      # Collect hit pixels as [cx, r, g, b] integer arrays for the JS canvas
      pixels =
        row_pixels
        |> Enum.filter(& &1 != nil)
        |> Enum.map(fn {cx, _cy, color} ->
          [cx,
           Color.scale_color_component(color.red),
           Color.scale_color_component(color.green),
           Color.scale_color_component(color.blue)]
        end)

      Phoenix.PubSub.broadcast(pubsub_server, topic, {:row_ready, %{y: cy, pixels: pixels}})
    end)
    |> Stream.run()

    total_ms = log_done(canvas_w, canvas_h, scene.total_start)
    Phoenix.PubSub.broadcast(pubsub_server, topic, {:trace_done, %{ms: total_ms}})
  end

  # Build the scene: canvas transform, eye, sphere, light, and record the start time
  defp build_scene(canvas_w, canvas_h, material, light, eye_position, sphere_r) do
    IO.puts("Tracing #{canvas_w}x#{canvas_h} canvas on #{System.schedulers_online()} cores...")
    # Transformation for the canvas: invert the y axis and translate (0,0) in the middle of the canvas
    canvas_trans = Matrix.identity_matrix4x4() |> Transformations.scaling(1, -1, 1) |> Transformations.translation(canvas_w / 2, canvas_h / 2, 0)
    # Sphere and material (radius is a world-space size independent of canvas resolution)
    sphere_trans = Matrix.identity_matrix4x4() |> Transformations.scaling(sphere_r, sphere_r, sphere_r)
    s = Sphere.sphere(sphere_trans, material)
    %{
      canvas_trans: canvas_trans,
      eye_position: eye_position,
      sphere: s,
      light: light,
      half_w: trunc(canvas_w / 2),
      half_h: trunc(canvas_h / 2),
      total_start: System.monotonic_time(:millisecond)
    }
  end

  # Render all rows in parallel via Task.async_stream; returns a stream of {:ok, {y, row_pixels}}
  defp render_rows(scene, canvas_w, canvas_h, opts) do
    %{canvas_trans: canvas_trans, eye_position: eye_position,
      sphere: sphere, light: light, half_w: half_w, half_h: half_h} = scene

    half_h..-half_h//-1
    |> Task.async_stream(fn y ->
      row_start = System.monotonic_time(:millisecond)
      row_pixels =
        for x <- -half_w..half_w do
          ray_endpoint = RTTuple.point(x, y, @wall_z)
          ray = Ray.ray(eye_position, RTTuple.normalize(RTTuple.minus(ray_endpoint, eye_position)))
          trace_pixel(ray, ray_endpoint, canvas_trans, sphere, light, canvas_w, canvas_h)
        end
      IO.puts("Row #{y} — #{System.monotonic_time(:millisecond) - row_start}ms [#{inspect(self())}]")
      {y, row_pixels}
    end, [max_concurrency: System.schedulers_online()] ++ opts)
  end

  # Log the completion summary; returns total_ms
  defp log_done(canvas_w, canvas_h, total_start, suffix \\ nil) do
    total_ms = System.monotonic_time(:millisecond) - total_start
    msg = "Done in #{total_ms}ms (#{Float.round(total_ms / (canvas_w * canvas_h) * 1000, 2)}µs/pixel)."
    IO.puts(if suffix, do: "#{msg} #{suffix}", else: msg)
    total_ms
  end

  defp find_hit(ray, sphere) do
    # Find the intersections and find the first non-negative hit
    Ray.ray_intersect(sphere, ray) |> Intersection.hit()
  end

  # Compute the color of a single pixel; returns {cx, cy, color} or nil on no hit
  defp trace_pixel(ray, ray_endpoint, canvas_trans, sphere, light, canvas_w, canvas_h) do
    case find_hit(ray, sphere) do
      nil ->
        nil
      hit ->
        # Transform the world coordinate ray_endpoint into canvas coordinates
        ray_endpoint_canvas = RTTuple.tuple_transform(canvas_trans, ray_endpoint)
        cx = max(min(round(ray_endpoint_canvas.x), canvas_w - 1), 0)
        cy = max(min(round(ray_endpoint_canvas.y), canvas_h - 1), 0)

        # Find the color of the point with the Phong model
        point = Ray.ray_position(ray, hit.time)
        normal = Sphere.sphere_normal_at(hit.object, point)
        eye = RTTuple.negate(ray.direction)
        color = Material.lighting(hit.object.material, light, point, eye, normal)

        {cx, cy, color}
    end
  end

end
