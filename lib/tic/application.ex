defmodule Tic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TicWeb.Telemetry,
      Tic.Repo,
      {DNSCluster, query: Application.get_env(:tic, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tic.PubSub},
      # Start a worker by calling: Tic.Worker.start_link(arg)
      # {Tic.Worker, arg},
      # Start to serve requests, typically the last entry
      TicWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tic.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TicWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
