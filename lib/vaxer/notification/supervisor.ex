defmodule Vaxer.Notification.Supervisor do
  use Supervisor
  require Logger
  alias Vaxer.Notification.Providers.{Twilio}

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      Twilio
    ]

    Logger.info("Starting notification supervisor...")

    Supervisor.init(children, strategy: :one_for_one)
  end
end
