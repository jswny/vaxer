defmodule Vaxer.Notification.Supervisor do
  use Supervisor
  require Logger
  alias Vaxer.Notification.Providers.{Twilio}

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    phone_number =
      Application.get_application(__MODULE__)
      |> Application.get_env(:phone_number)

    children = [
      {Twilio, phone_number: phone_number}
    ]

    Logger.info("Starting notification supervisor...")

    Supervisor.init(children, strategy: :one_for_one)
  end
end
