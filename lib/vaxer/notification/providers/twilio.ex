defmodule Vaxer.Notification.Providers.Twilio do
  use GenServer
  require Logger
  alias ExTwilio

  @prefix "Twilio notifier"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init([phone_number: phone_number]) do
    Logger.info("Starting #{@prefix} with phone number #{phone_number}...")
    notify("test")
    {:ok, %{phone_number: phone_number}}
  end

  def notify(source) do
    GenServer.cast(__MODULE__, {:notify, source})
  end

  @impl true
  def handle_cast({:notify, source}, %{phone_number: phone_number} = state) do
    Logger.info("#{@prefix} notifying about #{source}...")

    {:noreply, state}
  end
end
