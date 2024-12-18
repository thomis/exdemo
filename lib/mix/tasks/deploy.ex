defmodule Mix.Tasks.Deploy do
  @moduledoc "Deploy application"

  use Mix.Task

  @impl Mix.Task
  @shortdoc "Deploy application"
  def run(_) do
    {_, exit_code} = System.cmd("sh", ["./deploy", "prod"], into: IO.stream(:stdio, :line))

    if exit_code != 0 do
      Mix.raise("Exception while deploying application: exit code [#{exit_code}]")
    end
  end
end
