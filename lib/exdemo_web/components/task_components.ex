defmodule ExdemoWeb.TaskComponents do
  use Phoenix.Component

  def control(assigns) do
    ~H"""
    <div class="border rounded-md shadow-lg w-auto h-72 bg-blue-100 hover:bg-blue-200 transition duration-200 p-4 flex flex-col gap-5">
      <div class="text-lg font-bold">Control Panel</div>
      <div class="grid grid-cols-4 gap-5">
        <.label label="Tasks" text={@control.tasks} />
        <.label label="" text={} />
        <button class="w-full border border-green-500 text-green-800 rounded-md px-6 py-auto h-10 hover:bg-green-200">
          + Node
        </button>
        <button class="w-full border border-green-500 text-green-800 rounded-md px-6 py-auto h-10 hover:bg-green-200">
          - Node
        </button>
        <.label
          label="Pending"
          text={@control.tasks - @control.success - @control.failed - @control.running}
        />
        <.label label="Running" text={@control.running} />
        <.label label="Nodes" text={@control.nodes} />
        <.label label="Users" text={@control.users} />
        <.label label="Success" text={@control.success} />
        <.label label="Failed" text={@control.failed} />
      </div>
    </div>
    """
  end

  def user(assigns) do
    ~H"""
    <div class="border rounded-md shadow-lg hover:bg-slate-100 transition duration-200 w-auto h-72 p-4">
      <div class="text-lg font-bold">{@user.name} @ node N</div>
      <div class="flex flex-row gap-5">
        <div class="basis-1/2 flex flex-col gap-4">
          <div class="grid grid-cols-2 gap-5 mt-5">
            <.label label="Tasks" text={@user.tasks} />
            <.label label="" text={} />
            <.label label="Pending" text={@user.tasks - @user.running - @user.success - @user.failed} />
            <.label label="Running" text={@user.running} />
            <.label label="Success" text={@user.success} />
            <.label label="Failed" text={@user.failed} />
          </div>
        </div>
        <div class="basis-1/2 flex flex-col gap-2">
          <%= if @current_user == @user.name do %>
            <input
              class="rounded-md border-green-500 focus:border-green-500 focus:ring-2 focus:ring-green-500 h-10"
              type="text"
              placeholder="Number of tasks to execute"
            />
            <button class="border border-green-500 text-green-800 rounded-md px-6 py-auto h-10 hover:bg-green-200">
              Execute
            </button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def label(assigns) do
    ~H"""
    <div class="relative w-16">
      <span class="text-[0.7rem] absolute -top-3 left-0 text-slate-500">{@label}</span>
      <span class="font-bold">{@text}</span>
    </div>
    """
  end
end
