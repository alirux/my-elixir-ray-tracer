# Add the "start" task to Mix only for this project
# $ mix start
#
# 1) Use the namespace Mix.Tasks
defmodule Mix.Tasks.Start do
  # 2) Use the correct Mix module
  use Mix.Task

  # 3) Add the run method
  #def run(_), do: MyElixirRayTracer.Exercises.Clock.execute()
  def run(_), do: MyElixirRayTracer.Raytracer.trace()

end
