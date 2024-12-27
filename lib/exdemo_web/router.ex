defmodule ExdemoWeb.Router do
  use ExdemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExdemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ExdemoWeb.Authentication
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExdemoWeb do
    pipe_through :browser

    get "/logon", SessionController, :logon
    post "/register", SessionController, :register
  end

  scope "/", ExdemoWeb do
    pipe_through [:browser, :requires_registered_user]

    live "/", MonitorLive, :index
    live "/changelog", ChangelogLive, :index

    delete "/logoff", SessionController, :logoff

    import Phoenix.LiveDashboard.Router
    live_dashboard "/dashboard", metrics: ExdemoWeb.Telemetry

    # Catch-all route for undefined routes
    match :*, "/*path", SessionController, :not_found
  end

  defp requires_registered_user(conn, opts) do
    ExdemoWeb.Authentication.registered_user(conn, opts)
  end
end
