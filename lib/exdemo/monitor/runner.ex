defmodule Exdemo.Monitor.Runner do
  @moduledoc """
  GenServer Monitor - Deals with
  """

  use GenServer

  # Demo event interval
  @interval 15_000

  # Weighted probabilities for simulation
  @weights [{"healthy", 6}, {"warning", 3}, {"critical", 1}, {"muted", 1}]

  # State Count Sorting
  @state_sort_rules %{"healthy" => 1, "warning" => 2, "critical" => 3, "muted" => 4}

  # Component State Sorting
  @component_sort_rules %{"healthy" => 3, "warning" => 2, "critical" => 1, "muted" => 4}

  # Demo components and checks
  @components [
    %{
      name: "cph2.api",
      check: "endpoint",
      state: "muted",
      note:
        "Component is a prerequisite for the integration of modules such as ASPA, MiniASPA, Tecan 2.0, and the Manual Hub",
      output: "CheckHTTP CRITICAL: 502",
      muted_text: "Planned maintenance window from Friday 5pm - 7pm CET"
    },
    %{
      name: "container.adapter",
      check: "endpoint",
      state: "healthy",
      note:
        "Component is a prerequisite for all interactions with VSM, Aeos (Counter), Chronos (Sets), SMF (Samples)",
      output: "CheckHTTP CRITICAL: 502",
      muted_text: "Planned maintenance window from Friday 5pm - 7pm CET"
    },
    %{
      name: "container.validator",
      check: "endpoint",
      state: "healthy",
      note:
        "Compoent is a prerequisite for all store loading processes (Tube Stores Basel and Cambridge, Plate Store, Main Compound Stores)",
      output: "CheckHTTP CRITICAL: 502",
      muted_text: "Planned maintenance window from Friday 5pm - 7pm CET"
    },
    %{
      name: "biztalk.adapter",
      check: "endpoint",
      state: "healthy",
      note: "Component is a prerequisite for receving Chronos orders",
      output: "CheckHTTP CRITICAL: 502",
      muted_text: "Planned maintenance window from Friday 5pm - 7pm CET"
    },
    %{
      name: "aeos.adapter",
      check: "endpoint",
      state: "muted",
      note: "Component is a prerequisite for all Aeos interactions",
      output: "CheckHTTP CRITICAL: 502",
      muted_text: "Planned maintenance window from Friday 5pm - 7pm CET"
    },
    %{
      name: "chba@compoundhub_chbs_prod",
      check: "connectivity",
      state: "healthy",
      note:
        "CPH 1.0 fulfillment database is a prerequisite for the integration of CPH Application Suite",
      output: "ORA-12154: Cannot connect to database",
      muted_text: "Planned maintenance window from Friday 5pm - 7pm CET"
    },
    %{
      name: "chba@compoundhub_chbs_prod",
      check: "validity",
      state: "healthy",
      note:
        "CPH 1.0 fulfillment database is a prerequisite for the integration of CPH Application Suite",
      output: "Invalid objects: p_container_adapter, v_whatever",
      muted_text: "Planned maintenance window from Friday 5pm - 7pm CET"
    },
    %{
      name: "cm_core@compoundhub_chbs_prod",
      check: "connectivity",
      state: "healthy",
      note:
        "CM Core database is a prerequisite for authorization, locations, modules and other core data",
      output: "ORA-12154: Cannot connect to database",
      muted_text: "Planned maintenance window from Friday 5pm - 7pm CET"
    },
    %{
      name: "cm_core@compoundhub_chbs_prod",
      check: "validity",
      state: "healthy",
      note:
        "CM Core database is a prerequisite for authorization, locations, modules and other core data",
      output: "Invalid objects: v_modules, p_job",
      muted_text: "Planned maintenance window from Friday 5pm - 7pm CET"
    }
  ]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  # Client API
  @doc """
  Method to get monitor state
  """
  def get_state do
    GenServer.call({:global, __MODULE__}, :state, :infinity)
  end

  def running? do
    case :global.whereis_name(__MODULE__) do
      pid when is_pid(pid) -> true
      :undefined -> false
    end
  end

  # Server
  @impl true
  def init(_opts) do
    schedule_timer()

    state = %{
      summary: summary(@components),
      components: @components,
      last_updated: DateTime.utc_now() |> Calendar.strftime("%A, %H:%M:%S")
    }

    {:ok, state}
  end

  @impl true
  def handle_info(:monitor_event, state) do
    schedule_timer()

    updated_components = update_random_state(state.components)

    state = %{
      summary: summary(updated_components),
      components: updated_components,
      last_updated: DateTime.utc_now() |> Calendar.strftime("%A, %H:%M:%S")
    }

    # broadcast
    Phoenix.PubSub.broadcast(Exdemo.PubSub, "monitor", "monitor_update")
    {:noreply, state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  defp schedule_timer do
    Process.send_after(self(), :monitor_event, @interval)
  end

  defp summary(components) do
    %{
      environment: "prd",
      state: summary_state(components),
      component_count: component_count(components),
      check_count: length(components),
      states: group_by_state(components)
    }
  end

  defp summary_state(components) do
    cond do
      Enum.any?(components, &(&1.state == "critical")) -> "critical"
      Enum.any?(components, &(&1.state == "warning")) -> "warning"
      true -> "healthy"
    end
  end

  defp group_by_state(components) do
    components
    # Group by the state field
    |> Enum.group_by(& &1.state)
    # Map each group to {state, count}
    |> Enum.map(fn {state, list} ->
      {state, length(list)}
    end)
    |> Enum.sort_by(fn {state, _count} -> Map.get(@state_sort_rules, state) end)
  end

  defp random_state do
    Enum.reduce(@weights, [], fn {state, weight}, acc ->
      acc ++ List.duplicate(state, weight)
    end)
    |> Enum.random()
  end

  defp update_random_state(components) do
    Enum.map(components, fn component ->
      if Enum.random([true, false]) do
        %{component | state: random_state()}
      else
        component
      end
    end)
    |> sort_components()
  end

  defp sort_components(components) do
    components
    |> Enum.sort_by(fn %{state: state, name: name} ->
      {Map.get(@component_sort_rules, state, 5), name}
    end)
  end

  defp component_count(components) do
    Enum.uniq_by(components, fn %{name: name} -> name end)
    |> Enum.count()
  end
end
