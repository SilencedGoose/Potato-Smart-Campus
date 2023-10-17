defmodule SensorLiveview.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SensorLiveviewWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SensorLiveview.PubSub},
      # Start Finch
      {Finch, name: SensorLiveview.Finch},
      # Start the Endpoint (http/https)
      SensorLiveviewWeb.Endpoint
      # Start a worker by calling: SensorLiveview.Worker.start_link(arg)
      # {SensorLiveview.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SensorLiveview.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SensorLiveviewWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
