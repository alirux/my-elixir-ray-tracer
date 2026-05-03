defmodule RayTracerWebWeb.TracerLive do
  use RayTracerWebWeb, :live_view

  alias MyElixirRayTracer.Raytracer

  @topic "raytracer:render"
  @pubsub RayTracerWeb.PubSub

  def mount(_params, _session, socket) do
    {:ok, assign(socket, status: :idle, rows_done: 0, total_ms: nil)}
  end

  def handle_event("start_trace", _params, socket) do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
    Task.start(fn -> Raytracer.trace_streaming(@topic, @pubsub) end)
    {:noreply,
     socket
     |> assign(status: :tracing, rows_done: 0, total_ms: nil)
     |> push_event("clear_canvas", %{})}
  end

  def handle_info({:row_ready, row_data}, socket) do
    {:noreply,
     socket
     |> assign(rows_done: socket.assigns.rows_done + 1)
     |> push_event("row_ready", row_data)}
  end

  def handle_info({:trace_done, %{ms: ms}}, socket) do
    Phoenix.PubSub.unsubscribe(@pubsub, @topic)
    {:noreply, assign(socket, status: :done, total_ms: ms)}
  end

  def render(assigns) do
    ~H"""
    <div style="font-family: monospace; padding: 24px;">
      <h2 style="margin: 0 0 12px; font-size: 18px;">Elixir Ray Tracer</h2>
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
      <canvas id="ray-canvas" width="600" height="600"
              style="display: block; background: #000; border: 1px solid #333;"
              phx-hook="RayCanvas" phx-update="ignore">
      </canvas>
    </div>
    """
  end
end
