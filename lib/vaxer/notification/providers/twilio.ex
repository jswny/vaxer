defmodule Vaxer.Notification.Providers.Twilio do
  use GenServer
  require Logger
  alias ExTwilio

  @prefix "Twilio notifier"

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    Logger.info("Starting #{@prefix}...")

    {:ok, %{}}
  end

  def notify(source) do
    GenServer.cast(__MODULE__, {:notify, source})
  end

  @impl true
  def handle_cast({:notify, source}, state) do
    Logger.info("#{@prefix} notifying about #{source}...")

    {:noreply, state}
  end
end
