defmodule ExdemoWeb.MonitorLive do
  use ExdemoWeb, :live_view

  @filter_unhealthy ["warning", "critical", "muted"]
  @filter_all ["healthy", "warning", "critical", "muted"]

  def mount(_params, %{"username" => username} = _args, socket) do
    if connected?(socket) do
      # subscribe to monitoring events
      Phoenix.PubSub.subscribe(Exdemo.PubSub, "monitor")

      # subscribe to node events
      Phoenix.PubSub.subscribe(Exdemo.PubSub, "node_monitor")

      # register new user and subscribe to user related events
      ExdemoWeb.Presence.track(self(), "users_online", "#{username} (#{Node.self()})", %{})
      ExdemoWeb.Endpoint.subscribe("users_online")
    end

    socket =
      socket
      |> assign(:current_user, username)
      |> assign(:users, get_users())
      |> assign(:nodes, get_nodes())
      |> load_monitor_data()
      |> assign(:control, %{
        filter: @filter_unhealthy,
        filter_selected: "unhealthy",
        all_states: @filter_all,
        show_users: false
      })

    {:ok, socket}
  end

  def handle_info("monitor_update", socket) do
    {:noreply, load_monitor_data(socket)}
  end

  def handle_info("node_update", socket) do
    {:noreply, socket |> assign(:nodes, get_nodes())}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, socket |> assign(:users, get_users())}
  end

  def handle_event("filter", %{"value" => value}, socket) do
    {filter, filter_selected} =
      case value do
        "all" -> {@filter_all, "all"}
        "unhealthy" -> {@filter_unhealthy, "unhealthy"}
        state -> {[state], state}
      end

    control =
      socket.assigns.control
      |> Map.put(:filter, filter)
      |> Map.put(:filter_selected, filter_selected)

    socket =
      socket
      |> assign(:control, control)

    {:noreply, socket}
  end

  def handle_event("show_users", _, socket) do
    control =
      socket.assigns.control
      |> Map.put(:show_users, !socket.assigns.control.show_users)

    socket =
      socket
      |> assign(:control, control)

    {:noreply, socket}
  end

  defp load_monitor_data(socket) do
    if Exdemo.Monitor.Runner.running?() == true do
      state = Exdemo.Monitor.Runner.get_state()

      socket
      |> assign(:summary, state.summary)
      |> assign(:components, state.components)
      |> assign(:last_updated, state.last_updated)
    else
      :timer.sleep(500)
      load_monitor_data(socket)
    end
  end

  defp get_nodes do
    [Node.self() | Node.list()]
    |> Enum.sort()
  end

  defp get_users do
    ExdemoWeb.Presence.list("users_online")
    |> Enum.map(fn {username_node, %{metas: metas}} -> "#{username_node} [#{length(metas)}]" end)
    |> Enum.sort()
  end
end
