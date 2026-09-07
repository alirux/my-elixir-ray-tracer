defmodule RayTracerWebWeb.PageController do
  use RayTracerWebWeb, :controller

  def privacy(conn, _params) do
    render(conn, :privacy, page_title: "Privacy Policy")
  end
end
