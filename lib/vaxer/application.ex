defmodule Vaxer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Vaxer.{Notification, Web}

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Vaxer.Worker.start_link(arg)
      # {Vaxer.Worker, arg}
      Web.Supervisor,
      Notification.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vaxer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
