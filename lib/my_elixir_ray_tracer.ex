defmodule MyElixirRayTracer do
  alias Mix.Shell.IO, as: Shell
  @moduledoc """
  Documentation for MyElixirRayTracer.
  """

  #use Application
  # @doc """
  # Start the application
  # """
  # def start(_type, _args) do
  #   IO.puts "starting"
  #   {'ok', self()}
  # end

  def projectile do
    Shell.info("Started")
  end

  @doc """
  Hello world.
  """
  def hello do
    :world
  end

end
