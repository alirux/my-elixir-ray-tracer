defmodule RayTracerWebWeb.PageHTML do
  @moduledoc """
  HTML templates for the plain (non-LiveView) pages, such as the privacy policy.
  """
  use RayTracerWebWeb, :html

  embed_templates("page_html/*")
end
