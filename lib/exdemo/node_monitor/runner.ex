defmodule Exdemo.NodeMonitor.Runner do
  @moduledoc """
    Module responsible to monitor nodes and start/monitor Monitor.Runner process
  """
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :net_kernel.monitor_nodes(true, node_type: :all)
    maybe_start_monitor_runner()
    {:ok, []}
  end

  def handle_info({:nodeup, node, _}, state) do
    IO.puts("Node joined: #{node}")
    Phoenix.PubSub.broadcast(Exdemo.PubSub, "node_monitor", "node_update")
    {:noreply, state}
  end

  def handle_info({:nodedown, node, _}, state) do
    IO.puts("Node left: #{node}")
    Phoenix.PubSub.broadcast(Exdemo.PubSub, "node_monitor", "node_update")
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :process, _pid, _reason}, state) do
    IO.puts("Exdemo.Monitor.Runner seems down")
    maybe_start_monitor_runner()
    {:noreply, state}
  end

  def handle_info(other, state) do
    IO.puts("Other message: #{inspect(other)}")
    {:noreply, state}
  end

  defp maybe_start_monitor_runner do
    pid =
      case Exdemo.Monitor.Runner.start_link([]) do
        {:ok, pid} ->
          IO.puts("monitor runner has been started")
          pid

        {:error, {:already_started, pid}} ->
          IO.puts("monitor runner already started")
          pid
      end

    Process.monitor(pid)
  end
end
