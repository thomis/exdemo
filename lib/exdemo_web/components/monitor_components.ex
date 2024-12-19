defmodule ExdemoWeb.MonitorComponents do
  @moduledoc """
    Module with user interface monitoring components
  """

  use Phoenix.Component

  attr :nodes, :list, doc: "A list of node names"

  def nodes(assigns) do
    ~H"""
    <p class="font-thin w-full pb-4 text-slate-400 flex flex-row flex-wrap gap-x-3 gap-y-0 items-center justify-center">
      <%= for node <- @nodes do %>
        <span class={if node == node_prefix(Node.self()), do: "text-green-600 font-medium"}>
          {node}
        </span>
      <% end %>
    </p>
    """
  end

  attr :control, :map, doc: "A control map with relevant values"

  def control(assigns) do
    ~H"""
    <div class="flex flex-wrap gap-1 justify-end">
      <button
        phx-click="show_users"
        class={"flex items-center justify-center " <> get_class_selected(@control.show_users, true)}
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 -960 960 960" width="24px" fill="#000000">
          <path d="M480-480q-66 0-113-47t-47-113q0-66 47-113t113-47q66 0 113 47t47 113q0 66-47 113t-113 47ZM160-160v-112q0-34 17.5-62.5T224-378q62-31 126-46.5T480-440q66 0 130 15.5T736-378q29 15 46.5 43.5T800-272v112H160Zm80-80h480v-32q0-11-5.5-20T700-306q-54-27-109-40.5T480-360q-56 0-111 13.5T260-306q-9 5-14.5 14t-5.5 20v32Zm240-320q33 0 56.5-23.5T560-640q0-33-23.5-56.5T480-720q-33 0-56.5 23.5T400-640q0 33 23.5 56.5T480-560Zm0-80Zm0 400Z" />
        </svg>
      </button>
      <%= for state <- @control.all_states do %>
        <button
          phx-click="filter"
          value={state}
          class={get_class_selected(state, @control.filter_selected)}
        >
          {state}
        </button>
      <% end %>
      <button
        phx-click="filter"
        value="unhealthy"
        class={get_class_selected("unhealthy", @control.filter_selected)}
      >
        unhealthy
      </button>
      <button
        phx-click="filter"
        value="all"
        class={get_class_selected("all", @control.filter_selected)}
      >
        all
      </button>
    </div>
    """
  end

  attr :summary, :map, doc: "A summary map with relevant values"

  def summary(assigns) do
    ~H"""
    <div class={"rounded-md shadow-lg w-auto h-72 p-4 flex flex-col gap-7 " <> get_class(@summary.state)}>
      <div class={"text-2xl font-bold " <> get_text_class(@summary.state) }>Summary</div>
      <div class="grid grid-cols-4 gap-5">
        <.label label="Environment" text={@summary.environment} />
        <.label label="State" text={@summary.state} />
        <.label label="Components" text={@summary.component_count} />
        <.label label="Checks" text={@summary.check_count} />
      </div>
      <div class="grid grid-cols-4 gap-5">
        <%= for {state, count} <- @summary.states do %>
          <.label
            class={"font-bold text-lg text-center w-full " <> get_text_class(state)}
            label={state}
            text={count}
          />
        <% end %>
      </div>
    </div>
    """
  end

  attr :users, :list, default: [], doc: "A list of user strings with node and instance count"

  def users(assigns) do
    ~H"""
    <div class="rounded-md shadow-lg w-auto h-72 p-4 flex flex-col gap-5 border border-blue-300 bg-gradient-to-b from-blue-200 to-blue-50 hover:from-blue-300 hover:to-blue-100 transition duration-200">
      <div class="text-lg font-bold text-ellipsis text-blue-600">Users [{Enum.count(@users)}]</div>
      <div class="grid grid-cols-1 gap-1 overflow-auto overscroll-none">
        <%= for user <- @users do %>
          <span>{user}</span>
        <% end %>
      </div>
    </div>
    """
  end

  attr :component, :map, doc: "A component map with relevant values"

  def component(assigns) do
    ~H"""
    <div class={"rounded-md shadow-lg w-auto min-h-72 p-4 flex flex-col gap-5 " <> get_class(@component.state) }>
      <div class={"text-lg font-bold text-ellipsis overflow-hidden " <> get_text_class(@component.state)}>
        {@component.name}
      </div>
      <div class="grid grid-cols-2 gap-5">
        <.label label="Check" text={@component.check} />
        <.label label="State" text={@component.state} />
      </div>
      <.label
        label="Check Output"
        text={@component.output}
        class="text-default w-full text-ellipsis overflow-hidden"
      />
      <%= if @component.state == "muted" do %>
        <.label
          label="Information"
          text={@component.muted_text}
          class="text-default w-full text-ellipsis overflow-hidden"
        />
      <% end %>
      <.label
        label="Note"
        text={@component.note}
        class="text-default w-full text-ellipsis overflow-hidden"
      />
    </div>
    """
  end

  attr :class, :string, default: "font-bold text-lg text-center w-full"

  attr :label, :string

  attr :text, :string

  def label(assigns) do
    ~H"""
    <div class="relative">
      <span class="text-[0.7rem] absolute -top-3 left-0 text-slate-500">{@label}</span>
      <span class={@class}>{@text}</span>
    </div>
    """
  end

  defp get_class_selected(is, selected) do
    if is == selected do
      "border border-slate-500 bg-slate-300 hover:bg-slate-400 rounded-md p-auto w-24 h-8"
    else
      "border border-slate-500 bg-slate-100 hover:bg-slate-200 rounded-md p-auto w-24 h-8"
    end
  end

  defp get_text_class("healthy"), do: "text-green-600"
  defp get_text_class("warning"), do: "text-orange-500"
  defp get_text_class("critical"), do: "text-red-600"
  defp get_text_class("muted"), do: "text-slate-600"
  defp get_text_class(_), do: ""

  defp get_class("healthy"),
    do:
      "border border-green-300 bg-gradient-to-b from-green-200 to-green-50 hover:from-green-300 hover:to-green-100 transition duration-200"

  defp get_class("warning"),
    do:
      "border border-orange-200 bg-gradient-to-b from-orange-100 to-orange-50 hover:from-orange-200 hover:to-orange-100 transition duration-200"

  defp get_class("critical"),
    do:
      "border border-red-300 bg-gradient-to-b from-red-200 to-red-50 hover:from-red-300 hover:to-red-100 transition duration-200"

  defp get_class("muted"),
    do:
      "border border-slate-300 bg-gradient-to-b from-slate-200 to-slate-50 hover:from-slate-300 hover:to-slate-100 transition duration-200"

  defp get_class(_), do: ""

  defp node_prefix(node) do
    String.split("#{node}", "@") |> List.first()
  end
end
