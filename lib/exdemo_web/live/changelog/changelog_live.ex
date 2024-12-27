defmodule ExdemoWeb.ChangelogLive do
  use ExdemoWeb, :live_view

  def mount(_params, %{"username" => username, "session_id" => session_id} = _args, socket)
      when is_binary(session_id) do
    socket =
      socket
      |> assign(:current_user, username)
      |> assign(:changelog_entries, Exdemo.Helper.load_changelog())

    {:ok, socket}
  end

  # handles access without session_id (initial implementation)
  def mount(_params, %{"username" => _username} = _args, socket) do
    {:ok, redirect(socket, to: ~p"/logon")}
  end
end
