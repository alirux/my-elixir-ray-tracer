defmodule RayTracerWebWeb.TracerLive do
  use RayTracerWebWeb, :live_view

  alias MyElixirRayTracer.Raytracer

  @pubsub RayTracerWeb.PubSub

  @sizes [{300, 300}, {600, 600}]
  def sizes, do: @sizes

  def mount(_params, _session, socket) do
    topic = "raytracer:render:#{socket.id}"
    {:ok, assign(socket, status: :idle, rows_done: 0, total_ms: nil, topic: topic, canvas_w: 300, canvas_h: 300)}
  end

  def handle_event("set_size", %{"size" => size}, socket) do
    [w, h] = String.split(size, "x") |> Enum.map(&String.to_integer/1)
    {:noreply, assign(socket, canvas_w: w, canvas_h: h)}
  end

  def handle_event("start_trace", _params, socket) do
    %{topic: topic, canvas_w: w, canvas_h: h} = socket.assigns
    Phoenix.PubSub.subscribe(@pubsub, topic)
    Task.start(fn -> Raytracer.trace_streaming(topic, @pubsub, w, h) end)
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

  def render(assigns) do
    ~H"""
    <div style="font-family: monospace; padding: 24px;">
      <h2 style="margin: 0 0 12px; font-size: 18px;">
        Elixir Ray Tracer
        <a href="https://github.com/alirux/my-elixir-ray-tracer"
           target="_blank" rel="noopener noreferrer"
           style="margin-left: 12px; font-size: 13px; font-weight: normal; color: #888; text-decoration: none;"
           onmouseover="this.style.color='#ccc'" onmouseout="this.style.color='#888'">
          GitHub ↗
        </a>
      </h2>
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
