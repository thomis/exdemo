defmodule ExdemoWeb.SessionController do
  use ExdemoWeb, :controller

  @max_username_length 20

  def logon(conn, _params) do
    render(conn, :logon)
  end

  def register(conn, %{"username" => username}) do
    cleaned_username =
      username
      # Remove leading and trailing spaces
      |> String.trim()
      # Remove special characters and spaces
      |> String.replace(~r/[^a-zA-Z0-9._-]/, "")

    if String.length(cleaned_username) > @max_username_length do
      conn
      |> put_flash(:error, "Username must be #{@max_username_length} characters or fewer.")
      # Redirect back to the registration page
      |> redirect(to: ~p"/logon")
    else
      conn
      |> put_session(:session_id, UUID.uuid4())
      |> put_session(:username, cleaned_username)
      |> redirect(to: ~p"/")
    end
  end

  def logoff(conn, _params) do
    Phoenix.PubSub.broadcast(Exdemo.PubSub, "user", %{
      event: "logoff",
      session_id: get_session(conn, :session_id)
    })

    conn
    |> clear_session
    |> redirect(to: ~p"/logon")
  end

  def not_found(conn, _params) do
    render(conn, "not_found.html")
  end
end
