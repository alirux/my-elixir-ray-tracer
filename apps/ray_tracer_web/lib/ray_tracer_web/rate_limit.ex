defmodule RayTracerWeb.RateLimit do
  @moduledoc """
  Per-IP rate limiter for render requests, backed by Hammer's ETS backend.

  Use `RayTracerWeb.RateLimit.hit(key, scale_ms, limit)` which returns
  `{:allow, count}` or `{:deny, ms_until_next_window}`.
  """
  use Hammer, backend: :ets
end
