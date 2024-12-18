defmodule Mix.Tasks.Build do
  @moduledoc "Mix task to build release of appliation"

  use Mix.Task

  @impl Mix.Task
  @shortdoc "Build release of application"
  def run(_) do
    {_, exit_code} = System.cmd("sh", ["./build"], into: IO.stream(:stdio, :line))

    if exit_code != 0 do
      Mix.raise("Exception while building application release: exit code [#{exit_code}]")
    end
  end
end
