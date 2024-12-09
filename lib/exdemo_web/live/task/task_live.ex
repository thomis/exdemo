defmodule ExdemoWeb.TaskLive do
  use ExdemoWeb, :live_view

  @users [
    %{name: "Thomi", tasks: 4, success: 1, failed: 1, running: 1},
    %{name: "Freddy", tasks: 4, success: 1, failed: 1, running: 1},
    %{name: "Fritz", tasks: 4, success: 1, failed: 1, running: 2},
    %{name: "Nadal", tasks: 4, success: 1, failed: 1, running: 1},
    %{name: "Elvis", tasks: 4, success: 1, failed: 1, running: 0},
    %{name: "Daniela", tasks: 4, success: 1, failed: 1, running: 0},
    %{name: "Belinda", tasks: 4, success: 1, failed: 1, running: 0}
  ]

  def mount(_params, _args, socket) do
    sum = sum_fields(@users)

    socket =
      socket
      |> assign(:control, %{
        nodes: 3,
        users: length(@users),
        tasks: sum.tasks,
        success: sum.success,
        failed: sum.failed,
        running: sum.running
      })
      |> assign(:users, @users)
      |> assign(:current_user, "Thomi")

    {:ok, socket}
  end

  defp sum_fields(users) do
    Enum.reduce(users, %{tasks: 0, success: 0, failed: 0, running: 0}, fn user, acc ->
      %{
        tasks: acc.tasks + user.tasks,
        success: acc.success + user.success,
        failed: acc.failed + user.failed,
        running: acc.running + user.running
      }
    end)
  end
end
