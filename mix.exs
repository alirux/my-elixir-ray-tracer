defmodule MyElixirRayTracer.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      listeners: [Phoenix.CodeReloader],
      releases: [
        ray_tracer_web: [
          applications: [
            my_elixir_ray_tracer: :permanent,
            ray_tracer_web: :permanent
          ]
        ]
      ]
    ]
  end

  defp deps do
    []
  end
end
