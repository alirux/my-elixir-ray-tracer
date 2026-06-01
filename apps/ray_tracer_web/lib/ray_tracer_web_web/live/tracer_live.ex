defmodule RayTracerWebWeb.TracerLive do
  use RayTracerWebWeb, :live_view

  alias MyElixirRayTracer.Raytracer
  alias MyElixirRayTracer.Material
  alias MyElixirRayTracer.Color

  @pubsub RayTracerWeb.PubSub

  @sizes [{300, 300}, {600, 600}]
  def sizes, do: @sizes

  @default_material %{color: "#ff33ff", ambient: 0.1, diffuse: 0.9, specular: 0.9, shininess: 100}

  def mount(_params, _session, socket) do
    topic = "raytracer:render:#{socket.id}"
    {:ok, assign(socket,
      status: :idle, rows_done: 0, total_ms: nil,
      topic: topic, canvas_w: 300, canvas_h: 300,
      mat: @default_material
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

  def handle_event("start_trace", _params, socket) do
    %{topic: topic, canvas_w: w, canvas_h: h, mat: mat} = socket.assigns
    Phoenix.PubSub.subscribe(@pubsub, topic)
    material = build_material(mat)
    Task.start(fn -> Raytracer.trace_streaming(topic, @pubsub, w, h, material) end)
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

      <%!-- Canvas size --%>
      <div style="margin-bottom: 8px;">
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

      <%!-- Material parameters --%>
      <form phx-change="set_material" style="margin-bottom: 12px; display: grid; grid-template-columns: auto 1fr auto; align-items: center; gap: 4px 12px; max-width: 420px;">
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

      <%!-- Start button --%>
      <div style="margin-bottom: 12px;">
        <button phx-click="start_trace" disabled={@status == :tracing}
                style="padding: 8px 20px; cursor: pointer; font-family: monospace;">
          <%= cond do %>
            <% @status == :tracing -> %>Tracing… (<%= @rows_done %> rows done)
            <% @status == :done    -> %>Render Again
            <% true                -> %>Start Render
          <% end %>
        </button>
        <%= if @total_ms do %>
          <span style="margin-left: 16px; font-size: 12px; color: #888;">
            Rendered in <%= @total_ms %>ms
          </span>
        <% end %>
      </div>

      <canvas id="ray-canvas" width={@canvas_w} height={@canvas_h}
              style="display: block; background: #000; border: 1px solid #333;"
              phx-hook="RayCanvas" phx-update="ignore">
      </canvas>
    </div>
    """
  end
end
