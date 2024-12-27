defmodule Exdemo.Helper do
  @moduledoc """
  Various helper functions
  """

  def load_changelog() do
    load_changelog("#{:code.priv_dir(:exdemo)}/changelog.yaml")
  end

  def load_changelog(name) do
    case YamlElixir.read_from_file(name) do
      {:ok, items} ->
        items

      {:error, %YamlElixir.FileNotFoundError{}} ->
        [
          %{title: "n/a", text: ["Unable to find file [#{name}]"]}
        ]

      {:error, %YamlElixir.ParsingError{}} ->
        [
          %{title: "n/a", text: ["Unable to parse file [#{name}]"]}
        ]
    end
  end
end
