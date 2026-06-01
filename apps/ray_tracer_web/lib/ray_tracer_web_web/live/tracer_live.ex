defmodule RayTracerWebWeb.TracerLive do
  use RayTracerWebWeb, :live_view

  alias MyElixirRayTracer.Raytracer
  alias MyElixirRayTracer.Material
  alias MyElixirRayTracer.Color
  alias MyElixirRayTracer.PointLight
  alias MyElixirRayTracer.Tuple, as: RTTuple

  @pubsub RayTracerWeb.PubSub

  @sizes [{300, 300}, {600, 600}]
  def sizes, do: @sizes

  @default_material %{color: "#ff33ff", ambient: 0.1, diffuse: 0.9, specular: 0.9, shininess: 100}
  @default_light %{color: "#ffffff", x: -400, y: 400, z: -400}
  @default_eye %{x: 0, y: 0, z: -400}
  @default_sphere_r 100

  def mount(_params, _session, socket) do
    topic = "raytracer:render:#{socket.id}"
    {:ok, assign(socket,
      status: :idle, rows_done: 0, total_ms: nil,
      topic: topic, canvas_w: 300, canvas_h: 300,
      mat: @default_material,
      light: @default_light,
      eye: @default_eye,
      sphere_r: @default_sphere_r,
      cores: System.schedulers_online()
    )}
  end

  def handle_event("set_size", %{"size" => size}, socket) do
    [w, h] = String.split(size, "x") |> Enum.map(&String.to_integer/1)
    {:noreply, assign(socket, canvas_w: w, canvas_h: h)}
  end

  def handle_event("set_material", params, socket) do
    mat = %{
      color:     params["color"],
      ambient:   parse_float(params["ambient"]),
      diffuse:   parse_float(params["diffuse"]),
      specular:  parse_float(params["specular"]),
      shininess: parse_float(params["shininess"])
    }
    {:noreply, assign(socket, mat: mat)}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, mat: @default_material, light: @default_light, eye: @default_eye, sphere_r: @default_sphere_r)}
  end

  def handle_event("set_sphere", %{"radius" => r}, socket) do
    {:noreply, assign(socket, sphere_r: parse_int(r))}
  end

  def handle_event("set_eye", params, socket) do
    eye = %{x: parse_int(params["x"]), y: parse_int(params["y"]), z: parse_int(params["z"])}
    {:noreply, assign(socket, eye: eye)}
  end

  def handle_event("set_light", params, socket) do
    light = %{
      color: params["color"],
      x: parse_int(params["x"]),
      y: parse_int(params["y"]),
      z: parse_int(params["z"])
    }
    {:noreply, assign(socket, light: light)}
  end

  def handle_event("start_trace", _params, socket) do
    %{topic: topic, canvas_w: w, canvas_h: h, mat: mat, light: light_params, eye: eye_params, sphere_r: sphere_r} = socket.assigns
    Phoenix.PubSub.subscribe(@pubsub, topic)
    material = build_material(mat)
    light = build_light(light_params)
    eye_position = RTTuple.point(eye_params.x, eye_params.y, eye_params.z)
    Task.start(fn -> Raytracer.trace_streaming(topic, @pubsub, w, h, material, light, eye_position, sphere_r) end)
    {:noreply,
     socket
     |> assign(status: :tracing, rows_done: 0, total_ms: nil)
     |> push_event("resize_canvas", %{width: w, height: h})}
  end

  def handle_info({:row_ready, row_data}, socket) do
    {:noreply,
     socket
     |> assign(rows_done: socket.assigns.rows_done + 1)
     |> push_event("row_ready", row_data)}
  end

  def handle_info({:trace_done, %{ms: ms}}, socket) do
    Phoenix.PubSub.unsubscribe(@pubsub, socket.assigns.topic)
    {:noreply, assign(socket, status: :done, total_ms: ms)}
  end

  def terminate(_reason, socket) do
    Phoenix.PubSub.unsubscribe(@pubsub, socket.assigns.topic)
  end

  # Parse hex color "#RRGGBB" into a Material Color struct
  defp build_material(%{color: hex, ambient: ambient, diffuse: diffuse, specular: specular, shininess: shininess}) do
    {r, g, b} = hex_to_rgb(hex)
    Material.material(Color.color(r, g, b), ambient, diffuse, specular, shininess)
  end

  defp hex_to_rgb("#" <> hex) do
    {r, _} = Integer.parse(String.slice(hex, 0, 2), 16)
    {g, _} = Integer.parse(String.slice(hex, 2, 2), 16)
    {b, _} = Integer.parse(String.slice(hex, 4, 2), 16)
    {r / 255, g / 255, b / 255}
  end

  defp build_light(%{color: hex, x: x, y: y, z: z}) do
    {r, g, b} = hex_to_rgb(hex)
    PointLight.point_light(RTTuple.point(x, y, z), Color.color(r, g, b))
  end

  defp parse_int(s) when is_binary(s) do
    {i, _} = Integer.parse(s)
    i
  end
  defp parse_int(n) when is_integer(n), do: n

  defp parse_float(s) when is_binary(s) do
    case Float.parse(s) do
      {f, _} -> f
      :error  -> String.to_integer(s) * 1.0
    end
  end
  defp parse_float(n) when is_number(n), do: n * 1.0

  def render(assigns) do
    ~H"""
    <div style="font-family: monospace; padding: 24px;">
      <h2 style="margin: 0 0 12px; font-size: 18px;">
        Elixir Ray Tracer
        <a href="https://github.com/alirux/my-elixir-ray-tracer"
           target="_blank" rel="noopener noreferrer"
           class="gh-link">
          GitHub ↗
        </a>
      </h2>

      <%
        s = 0.2
        clamp = fn v, lo, hi -> min(hi, max(lo, round(v))) end
        sr = max(4, round(@sphere_r * s))
        # Top view (X-Z)
        xz_ox = 130; xz_oz = 44
        ex_xz = clamp.(xz_ox + @eye.x   * s, 8, 252)
        ez_xz = clamp.(xz_oz - @eye.z   * s, 8, 232)
        lx_xz = clamp.(xz_ox + @light.x * s, 8, 252)
        lz_xz = clamp.(xz_oz - @light.z * s, 8, 232)
        # Front view (X-Y)
        xy_ox = 130; xy_oy = 120
        ex_xy = clamp.(xy_ox + @eye.x   * s, 8, 252)
        ey_xy = clamp.(xy_oy - @eye.y   * s, 8, 232)
        lx_xy = clamp.(xy_ox + @light.x * s, 8, 252)
        ly_xy = clamp.(xy_oy - @light.y * s, 8, 232)
        # Isometric 3D projection (ground plane = X-Z, Y vertical):
        #   +X → lower-right, +Y → up, +Z (away from viewer) → upper-right,
        #   -Z (toward viewer) → lower-left. Ground-level points (Y=0) stay
        #   at the sphere's vertical level, so height reads correctly.
        # svg_x = ox + (x + z) * cos30 * s3
        # svg_y = oy + (x - z) * sin30 * s3 - y * s3
        s3 = 0.13; iso_ox = 130; iso_oy = 120
        iso = fn x, y, z ->
          {clamp.(iso_ox + (x + z) * 0.866 * s3, 8, 252),
           clamp.(iso_oy + (x - z) * 0.5 * s3 - y * s3, 8, 232)}
        end
        iso_sr = max(4, round(@sphere_r * s3))
        {e3x, e3y} = iso.(@eye.x, @eye.y, @eye.z)
        {l3x, l3y} = iso.(@light.x, @light.y, @light.z)
        # Coordinate projections (drop lines): ground point + X/Z axis feet
        {egx, egy} = iso.(@eye.x, 0, @eye.z)     # eye ground (x,0,z)
        {eax, eay} = iso.(@eye.x, 0, 0)          # eye foot on X axis
        {ezx, ezy} = iso.(0, 0, @eye.z)          # eye foot on Z axis
        {lgx, lgy} = iso.(@light.x, 0, @light.z) # light ground (x,0,z)
        {lax, lay} = iso.(@light.x, 0, 0)        # light foot on X axis
        {lzx, lzy} = iso.(0, 0, @light.z)        # light foot on Z axis
        # Axis endpoints (length 850 world units)
        {axx, axy} = iso.(850, 0, 0)
        {ayx, ayy} = iso.(0, 850, 0)
        {azx, azy} = iso.(0, 0, 850)
        {nxx, nxy} = iso.(-650, 0, 0)   # -X stub
        {nyx, nyy} = iso.(0, -650, 0)   # -Y stub (below ground)
        {nzx, nzy} = iso.(0, 0, -560)   # -Z stub (toward viewer)
        # Arrowhead helper: tip (tx,ty), unit direction (dx,dy)
        arrowhead = fn tx, ty, dx, dy ->
          px = -dy; py = dx
          "#{tx},#{ty} #{round(tx - 8*dx + 4*px)},#{round(ty - 8*dy + 4*py)} #{round(tx - 8*dx - 4*px)},#{round(ty - 8*dy - 4*py)}"
        end
        arr_x  = arrowhead.(axx, axy, 0.866,  0.5)   # X: lower-right
        arr_y  = arrowhead.(ayx, ayy, 0.0,   -1.0)   # Y: up
        arr_z  = arrowhead.(azx, azy, 0.866, -0.5)   # +Z: upper-right (away)
      %>

      <%!-- Main two-column layout --%>
      <div style="display: flex; gap: 32px; align-items: flex-start;">

        <%!-- LEFT: all controls + buttons --%>
        <div style="flex-shrink: 0; width: 340px;">

          <%!-- Canvas size (image resolution) --%>
          <div style="margin-bottom: 12px;">
            <span style="margin-right: 12px; color: #888;">Canvas:</span>
            <%= for {w, h} <- sizes() do %>
              <label style="margin-right: 16px; cursor: pointer;">
                <input type="radio" name="size" value={"#{w}x#{h}"}
                       checked={@canvas_w == w && @canvas_h == h}
                       disabled={@status == :tracing}
                       phx-click="set_size" phx-value-size={"#{w}x#{h}"} />
                <%= w %>×<%= h %>
              </label>
            <% end %>
          </div>

          <%!-- Sphere radius (world units, independent of canvas) --%>
          <form phx-change="set_sphere" style="margin-bottom: 12px; display: grid; grid-template-columns: auto 1fr auto; align-items: center; gap: 4px 12px;">
            <label>Sphere</label>
            <input type="range" name="radius" min="20" max="280" step="10" value={@sphere_r} disabled={@status == :tracing} />
            <span style="font-size: 11px; color: #888; width: 36px; text-align: right; display: inline-block;"><%= @sphere_r %></span>
          </form>

          <%!-- Material --%>
          <form phx-change="set_material" style="margin-bottom: 12px; display: grid; grid-template-columns: auto 1fr auto; align-items: center; gap: 4px 12px;">
            <label>Color</label>
            <input type="color" name="color" value={@mat.color} disabled={@status == :tracing} style="width: 48px; height: 24px; padding: 0; border: none; cursor: pointer;" />
            <span></span>
            <label>Ambient</label>
            <input type="range" name="ambient" min="0" max="1" step="0.01" value={@mat.ambient} disabled={@status == :tracing} />
            <span style="font-size: 11px; color: #888; width: 36px; text-align: right; display: inline-block;"><%= @mat.ambient %></span>
            <label>Diffuse</label>
            <input type="range" name="diffuse" min="0" max="1" step="0.01" value={@mat.diffuse} disabled={@status == :tracing} />
            <span style="font-size: 11px; color: #888; width: 36px; text-align: right; display: inline-block;"><%= @mat.diffuse %></span>
            <label>Specular</label>
            <input type="range" name="specular" min="0" max="1" step="0.01" value={@mat.specular} disabled={@status == :tracing} />
            <span style="font-size: 11px; color: #888; width: 36px; text-align: right; display: inline-block;"><%= @mat.specular %></span>
            <label>Shininess</label>
            <input type="range" name="shininess" min="1" max="300" step="1" value={@mat.shininess} disabled={@status == :tracing} />
            <span style="font-size: 11px; color: #888; width: 36px; text-align: right; display: inline-block;"><%= @mat.shininess %></span>
          </form>

          <%!-- Eye --%>
          <form phx-change="set_eye" style="margin-bottom: 12px; display: grid; grid-template-columns: auto 1fr auto; align-items: center; gap: 4px 12px;">
            <label>Eye X</label>
            <input type="range" name="x" min="-600" max="600" step="10" value={@eye.x} disabled={@status == :tracing} />
            <span style="font-size: 11px; color: #888; width: 36px; text-align: right; display: inline-block;"><%= @eye.x %></span>
            <label>Eye Y</label>
            <input type="range" name="y" min="-600" max="600" step="10" value={@eye.y} disabled={@status == :tracing} />
            <span style="font-size: 11px; color: #888; width: 36px; text-align: right; display: inline-block;"><%= @eye.y %></span>
            <label>Eye Z</label>
            <input type="range" name="z" min="-800" max="-50" step="10" value={@eye.z} disabled={@status == :tracing} />
            <span style="font-size: 11px; color: #888; width: 36px; text-align: right; display: inline-block;"><%= @eye.z %></span>
          </form>

          <%!-- Light --%>
          <form phx-change="set_light" style="margin-bottom: 16px; display: grid; grid-template-columns: auto 1fr auto; align-items: center; gap: 4px 12px;">
            <label>Light color</label>
            <input type="color" name="color" value={@light.color} disabled={@status == :tracing} style="width: 48px; height: 24px; padding: 0; border: none; cursor: pointer;" />
            <span></span>
            <label>Light X</label>
            <input type="range" name="x" min="-600" max="600" step="10" value={@light.x} disabled={@status == :tracing} />
            <span style="font-size: 11px; color: #888; width: 36px; text-align: right; display: inline-block;"><%= @light.x %></span>
            <label>Light Y</label>
            <input type="range" name="y" min="-600" max="600" step="10" value={@light.y} disabled={@status == :tracing} />
            <span style="font-size: 11px; color: #888; width: 36px; text-align: right; display: inline-block;"><%= @light.y %></span>
            <label>Light Z</label>
            <input type="range" name="z" min="-600" max="600" step="10" value={@light.z} disabled={@status == :tracing} />
            <span style="font-size: 11px; color: #888; width: 36px; text-align: right; display: inline-block;"><%= @light.z %></span>
          </form>

          <%!-- Buttons + status --%>
          <div style="margin-bottom: 16px;">
            <button phx-click="start_trace" disabled={@status == :tracing}
                    style="padding: 8px 20px; cursor: pointer; font-family: monospace;">
              <%= cond do %>
                <% @status == :tracing -> %>Tracing… (<%= @rows_done %> rows done)
                <% @status == :done    -> %>Render Again
                <% true                -> %>Start Render
              <% end %>
            </button>
            <button phx-click="reset" disabled={@status == :tracing}
                    style="padding: 8px 16px; cursor: pointer; font-family: monospace; margin-left: 8px;">
              Reset
            </button>
            <div style="margin-top: 8px; font-size: 12px; color: #888;">
              <%= @cores %> cores
              <%= if @total_ms do %>
                · Rendered in <%= @total_ms %>ms
              <% end %>
            </div>
          </div>

        </div>

        <%!-- RIGHT: diagrams side by side + rendered canvas below --%>
        <div>

          <%!-- Diagrams 2x2 grid: TL=3D, TR=X-Y, BL=X-Z, BR=empty --%>
          <div style="display: grid; grid-template-columns: 260px 260px; gap: 16px; margin-bottom: 16px;">

            <%!-- Top-left: isometric 3D --%>
            <div>
              <div style="font-size: 10px; color: #555; margin-bottom: 4px;">3D view · isometric</div>
              <svg width="260" height="240" style="border: 1px solid #2a2a2a; background: #0d0d0d; display: block;">
                <%!-- +Z axis (away from viewer, upper-right, dashed) --%>
                <line x1="130" y1="120" x2={azx} y2={azy} stroke="#2a2a2a" stroke-width="1" stroke-dasharray="4,3"/>
                <polygon points={arr_z} fill="#2a2a2a"/>
                <text x={azx + 4} y={azy - 2} fill="#2a2a2a" font-size="9" font-family="monospace">+Z</text>
                <%!-- Negative axis halves (faint) --%>
                <line x1="130" y1="120" x2={nxx} y2={nxy} stroke="#2a2a2a" stroke-width="1"/>
                <line x1="130" y1="120" x2={nyx} y2={nyy} stroke="#2a2a2a" stroke-width="1"/>
                <line x1="130" y1="120" x2={nzx} y2={nzy} stroke="#2a2a2a" stroke-width="1"/>
                <text x="6" y="234" fill="#333" font-size="8" font-family="monospace">-Z toward viewer</text>
                <%!-- X axis (lower-right) --%>
                <line x1="130" y1="120" x2={axx} y2={axy} stroke="#555" stroke-width="1"/>
                <polygon points={arr_x} fill="#555"/>
                <text x={axx + 4} y={axy + 8} fill="#555" font-size="10" font-family="monospace">X</text>
                <%!-- Y axis (up) --%>
                <line x1="130" y1="120" x2={ayx} y2={ayy} stroke="#555" stroke-width="1"/>
                <polygon points={arr_y} fill="#555"/>
                <text x={ayx + 6} y={ayy + 9} fill="#555" font-size="10" font-family="monospace">Y</text>
                <%!-- Sphere --%>
                <circle cx="130" cy="120" r={iso_sr} fill={@mat.color} fill-opacity="0.25" stroke={@mat.color} stroke-width="1" stroke-dasharray="4,2"/>
                <circle cx="130" cy="120" r="2" fill={@mat.color}/>
                <%!-- Eye coordinate projections (drop lines) --%>
                <line x1={e3x} y1={e3y} x2={egx} y2={egy} stroke="#4af" stroke-width="1" opacity="0.25" stroke-dasharray="2,2"/>
                <line x1={egx} y1={egy} x2={eax} y2={eay} stroke="#4af" stroke-width="1" opacity="0.25" stroke-dasharray="2,2"/>
                <line x1={egx} y1={egy} x2={ezx} y2={ezy} stroke="#4af" stroke-width="1" opacity="0.25" stroke-dasharray="2,2"/>
                <circle cx={egx} cy={egy} r="2" fill="#4af" opacity="0.4"/>
                <circle cx={eax} cy={eay} r="2" fill="#4af" opacity="0.4"/>
                <circle cx={ezx} cy={ezy} r="2" fill="#4af" opacity="0.4"/>
                <%!-- Light coordinate projections (drop lines) --%>
                <line x1={l3x} y1={l3y} x2={lgx} y2={lgy} stroke="#ffd055" stroke-width="1" opacity="0.25" stroke-dasharray="2,2"/>
                <line x1={lgx} y1={lgy} x2={lax} y2={lay} stroke="#ffd055" stroke-width="1" opacity="0.25" stroke-dasharray="2,2"/>
                <line x1={lgx} y1={lgy} x2={lzx} y2={lzy} stroke="#ffd055" stroke-width="1" opacity="0.25" stroke-dasharray="2,2"/>
                <circle cx={lgx} cy={lgy} r="2" fill="#ffd055" opacity="0.4"/>
                <circle cx={lax} cy={lay} r="2" fill="#ffd055" opacity="0.4"/>
                <circle cx={lzx} cy={lzy} r="2" fill="#ffd055" opacity="0.4"/>
                <%!-- Lines to sphere --%>
                <line x1={e3x} y1={e3y} x2="130" y2="120" stroke="#4af"    stroke-width="1" opacity="0.5" stroke-dasharray="3,2"/>
                <line x1={l3x} y1={l3y} x2="130" y2="120" stroke="#ffd055" stroke-width="1" opacity="0.5" stroke-dasharray="3,2"/>
                <%!-- Eye --%>
                <circle cx={e3x} cy={e3y} r="6" fill="#4af"/>
                <text x={e3x + 8} y={e3y + 4} fill="#4af" font-size="9" font-family="monospace">eye</text>
                <%!-- Light --%>
                <circle cx={l3x} cy={l3y} r="6" fill="#ffd055"/>
                <text x={l3x + 8} y={l3y + 4} fill="#ffd055" font-size="9" font-family="monospace">light</text>
              </svg>
            </div>

            <%!-- Top-right: front view (X-Y) --%>
            <div>
              <div style="font-size: 10px; color: #555; margin-bottom: 4px;">front view · X-Y · Z⊙</div>
              <svg width="260" height="240" style="border: 1px solid #2a2a2a; background: #0d0d0d; display: block;">
                <line x1="130" y1="4"   x2="130" y2="236" stroke="#1a1a1a" stroke-width="1"/>
                <line x1="4"   y1="120" x2="256" y2="120" stroke="#1a1a1a" stroke-width="1"/>
                <line x1="130" y1="120" x2="248" y2="120" stroke="#333" stroke-width="1"/>
                <polygon points="252,120 244,116 244,124" fill="#333"/>
                <line x1="130" y1="120" x2="130" y2="12"  stroke="#333" stroke-width="1"/>
                <polygon points="130,8 126,16 134,16" fill="#333"/>
                <text x="240" y="114" fill="#444" font-size="10" font-family="monospace">X</text>
                <text x="134" y="18"  fill="#444" font-size="10" font-family="monospace">Y</text>
                <circle cx="130" cy="120" r="7" fill="none" stroke="#3a3a3a" stroke-width="1"/>
                <circle cx="130" cy="120" r="2" fill="#3a3a3a"/>
                <text x="140" y="116" fill="#3a3a3a" font-size="8" font-family="monospace">Z</text>
                <circle cx="130" cy="120" r={sr} fill={@mat.color} fill-opacity="0.25" stroke={@mat.color} stroke-width="1" stroke-dasharray="4,2"/>
                <text x="134" y="116" fill="#444" font-size="8" font-family="monospace">sphere</text>
                <line x1={ex_xy} y1={ey_xy} x2="130" y2="120" stroke="#4af"    stroke-width="1" opacity="0.4" stroke-dasharray="3,2"/>
                <line x1={lx_xy} y1={ly_xy} x2="130" y2="120" stroke="#ffd055" stroke-width="1" opacity="0.4" stroke-dasharray="3,2"/>
                <circle cx={ex_xy} cy={ey_xy} r="6" fill="#4af"/>
                <text x={ex_xy + 8} y={ey_xy + 4} fill="#4af"    font-size="9" font-family="monospace">eye</text>
                <circle cx={lx_xy} cy={ly_xy} r="6" fill="#ffd055"/>
                <text x={lx_xy + 8} y={ly_xy + 4} fill="#ffd055" font-size="9" font-family="monospace">light</text>
              </svg>
            </div>

            <%!-- Bottom-left: top view (X-Z) --%>
            <div>
              <div style="font-size: 10px; color: #555; margin-bottom: 4px;">top view · X-Z · Y⊙</div>
              <svg width="260" height="240" style="border: 1px solid #2a2a2a; background: #0d0d0d; display: block;">
                <line x1="130" y1="4"  x2="130" y2="236" stroke="#1a1a1a" stroke-width="1"/>
                <line x1="4"   y1="44" x2="256" y2="44"  stroke="#1a1a1a" stroke-width="1"/>
                <line x1="130" y1="44" x2="248" y2="44"  stroke="#333" stroke-width="1"/>
                <polygon points="252,44 244,40 244,48" fill="#333"/>
                <line x1="130" y1="44" x2="130" y2="12"  stroke="#333" stroke-width="1"/>
                <polygon points="130,8 126,16 134,16" fill="#333"/>
                <text x="240" y="38" fill="#444" font-size="10" font-family="monospace">X</text>
                <text x="134" y="18" fill="#444" font-size="10" font-family="monospace">Z</text>
                <text x="4"   y="234" fill="#2a2a2a" font-size="8" font-family="monospace">-Z toward viewer</text>
                <circle cx="130" cy="44" r="7" fill="none" stroke="#3a3a3a" stroke-width="1"/>
                <circle cx="130" cy="44" r="2" fill="#3a3a3a"/>
                <text x="140" y="40" fill="#3a3a3a" font-size="8" font-family="monospace">Y</text>
                <circle cx="130" cy="44" r={sr} fill={@mat.color} fill-opacity="0.25" stroke={@mat.color} stroke-width="1" stroke-dasharray="4,2"/>
                <text x="134" y="40" fill="#444" font-size="8" font-family="monospace">sphere</text>
                <line x1={ex_xz} y1={ez_xz} x2="130" y2="44" stroke="#4af"    stroke-width="1" opacity="0.4" stroke-dasharray="3,2"/>
                <line x1={lx_xz} y1={lz_xz} x2="130" y2="44" stroke="#ffd055" stroke-width="1" opacity="0.4" stroke-dasharray="3,2"/>
                <circle cx={ex_xz} cy={ez_xz} r="6" fill="#4af"/>
                <text x={ex_xz + 8} y={ez_xz + 4} fill="#4af"    font-size="9" font-family="monospace">eye</text>
                <circle cx={lx_xz} cy={lz_xz} r="6" fill="#ffd055"/>
                <text x={lx_xz + 8} y={lz_xz + 4} fill="#ffd055" font-size="9" font-family="monospace">light</text>
              </svg>
            </div>

            <%!-- Bottom-right: intentionally empty --%>
            <div></div>

          </div>

          <%!-- Rendered canvas --%>
          <canvas id="ray-canvas" width={@canvas_w} height={@canvas_h}
                  style="display: block; background: #000; border: 1px solid #333;"
                  phx-hook="RayCanvas" phx-update="ignore">
          </canvas>

        </div>
      </div>
    </div>
    """
  end
end
