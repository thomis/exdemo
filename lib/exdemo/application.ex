defmodule Exdemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExdemoWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:exdemo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Exdemo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Exdemo.Finch},
      # Start a worker by calling: Exdemo.Worker.start_link(arg)
      # {Exdemo.Worker, arg},
      # Start to serve requests, typically the last entry
      ExdemoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exdemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExdemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
