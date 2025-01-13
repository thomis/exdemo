defmodule ExdemoWeb.BreLive do
  use ExdemoWeb, :live_view

  @use_case_folder "./script/use_cases"
  @file_pattern ~r/\.rb$/
  @deplay_of_calculation 300

  def mount(_params, %{"username" => username, "session_id" => session_id} = _args, socket)
      when is_binary(session_id) do
    if connected?(socket) do
    end

    index = 0

    use_cases =
      load_use_cases(@use_case_folder, @file_pattern)
      |> Enum.sort_by(fn item -> [item.category, item.name] end)
      |> Enum.with_index()
      |> Enum.map(fn {item, index} -> Map.put(item, :id, index) end)

    socket =
      socket
      |> assign(current_user: username)
      |> assign(use_cases: use_cases)
      |> assign(request: Enum.at(use_cases, index).request)
      |> assign(index: 0)
      |> assign(result: "")
      |> assign(timer: nil)

    send(self(), :calculate)

    {:ok, socket}
  end

  def handle_event("key_left", _, socket) do
    index =
      cond do
        socket.assigns.index == nil -> length(socket.assigns.use_cases) - 1
        socket.assigns.index == 0 -> length(socket.assigns.use_cases) - 1
        true -> socket.assigns.index - 1
      end

    {:noreply,
     socket
     |> start_delayed_calculation()
     |> assign(index: index, request: Enum.at(socket.assigns.use_cases, index).request)}
  end

  def handle_event("key_right", _, socket) do
    index =
      cond do
        socket.assigns.index == nil -> 0
        socket.assigns.index == length(socket.assigns.use_cases) - 1 -> 0
        true -> socket.assigns.index + 1
      end

    {:noreply,
     socket
     |> start_delayed_calculation()
     |> assign(index: index, request: Enum.at(socket.assigns.use_cases, index).request)}
  end

  def handle_event("show", %{"index" => index}, socket) do
    index = String.to_integer(index)
    use_case = Enum.at(socket.assigns.use_cases, index)

    {:noreply,
     socket |> start_delayed_calculation() |> assign(index: index, request: use_case.request)}
  end

  def handle_event("calculate", %{"request" => request}, socket) do
    {:noreply, socket |> start_delayed_calculation() |> assign(request: request, index: nil)}
  end

  def handle_info(:delayed_calculation, socket) do
    send(self(), :calculate)
    {:noreply, socket}
  end

  def handle_info(:calculate, socket) do
    result = execute(socket.assigns.request)
    {:noreply, socket |> assign(result: result)}
  end

  defp execute(request) do
    command = "bundle"
    args = ["exec", "ruby", "run.rb", request]

    # Set the working directory to ./script
    opts = [cd: "./script"]

    {result, _exit_code} = System.cmd(command, args, opts)
    to_html(result)
  end

  defp to_html(string) do
    string
    |> String.replace("\n", "<br>")
    |> String.replace("\e[0m", "</span>", global: true)
    |> String.replace("\e[0;31;49m", "<span class=\"text-red-400\">", global: true)
    |> String.replace("\e[0;32;49m", "<span class=\"text-green-400\">", global: true)
    |> String.replace("\e[0;33;49m", "<span class=\"text-yellow-400\">", global: true)
    |> String.replace("\e[0;34;49m", "<span class=\"text-blue-400\">", global: true)
    |> String.replace("\e[0;35;49m", "<span class=\"text-violet-400\">", global: true)
    |> String.replace("\e[0;36;49m", "<span class=\"text-cyan-400\">", global: true)
    |> String.replace("\e[0;37;49m", "<span class=\"text-white\">", global: true)
    |> String.replace("\e[0;39;49m", "<span class=\"text-orange-400\">", global: true)
  end

  defp start_delayed_calculation(socket) do
    if socket.assigns.timer != nil do
      Process.cancel_timer(socket.assigns.timer)
    end

    socket
    |> assign(timer: Process.send_after(self(), :delayed_calculation, @deplay_of_calculation))
  end

  defp load_use_cases(folder, file_pattern) do
    folder
    |> Path.expand()
    |> load_use_cases_recursively(file_pattern)
  end

  defp load_use_cases_recursively(folder, file_pattern) do
    folder
    |> File.ls!()
    |> Enum.map(&Path.join(folder, &1))
    |> Enum.flat_map(fn path -> handle_path(folder, path, file_pattern) end)
  end

  defp handle_path(folder, path, file_pattern) do
    cond do
      File.dir?(path) ->
        load_use_cases_recursively(path, file_pattern)

      File.regular?(path) ->
        request =
          case File.read(path) do
            {:ok, content} -> content
            {:error, reason} -> "Exception while reading content of [#{path}]: #{reason}"
          end

        # it's a file
        [
          %{
            category: Path.basename(folder),
            name: Path.basename(path, ".rb"),
            request: request
          }
        ]

      true ->
        []
    end
  end
end
