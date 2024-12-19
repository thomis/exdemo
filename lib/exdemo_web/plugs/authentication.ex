defmodule ExdemoWeb.Authentication do
  import Plug.Conn
  import Phoenix.Controller

  @moduledoc """
  Exdemo  authentication module
  """

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _opts) do
    conn
    |> assign(:current_user, get_session(conn, :username))
  end

  @doc false
  def registered_user(%{assigns: %{current_user: user}} = conn, _opts)
      when is_binary(user) do
    conn
  end

  @doc false
  def registered_user(conn, _opts) do
    # Is called when unauthenticated in order to redirects to logon page
    conn
    |> redirect(to: "/logon")
    |> halt()
  end
end
