defmodule RayTracerWebWeb.TracerLiveTest do
  use RayTracerWebWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders the start button", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Start Render"
  end

  test "blocks rendering once the per-IP rate limit is exceeded", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    # Pre-exhaust the limiter for the keys the LiveView might use locally
    # (peer 127.0.0.1, or "unknown" when connect_info has no peer data).
    for key <- ["render:127.0.0.1", "render:unknown"] do
      for _ <- 1..20, do: RayTracerWeb.RateLimit.hit(key, 60_000, 20)
    end

    html = render_click(view, "start_trace")

    assert html =~ "Rate limit reached"
  end
end
