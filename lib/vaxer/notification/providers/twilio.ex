defmodule Vaxer.Notification.Providers.Twilio do
  use GenServer
  require Logger

  @prefix "Twilio notifier"

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], [])
  end

  @impl true
  def init(_opts) do
    Logger.info("Starting #{@prefix}...")

    {:ok, %{}}
  end
end
