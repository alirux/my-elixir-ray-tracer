defmodule MyElixirRayTracer do
  #alias Mix.Shell.IO, as: Shell
  @moduledoc """
  Documentation for MyElixirRayTracer.
  """

  use Application
  # @doc """
  # Start the application
  # """
  def start(_type, _args) do
    IO.puts "starting"
    main()
    {:ok, self()}
  end

  def main() do
    MyElixirRayTracer.Raytracer.trace()
  end

end
