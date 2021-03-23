defmodule Vaxer.Notification.Providers.Twilio do
  use GenServer
  require Logger
  alias ExTwilio

  @prefix "Twilio notifier"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init([twilio_phone_number: twilio_phone_number, notification_phone_numbers: notification_phone_numbers]) do
    Logger.info("Starting #{@prefix} with phone number #{twilio_phone_number} and notification phone numbers: #{Enum.join(notification_phone_numbers, ", ")}...")

    {:ok, %{twilio_phone_number: twilio_phone_number}}
  end

  def notify(source) do
    GenServer.cast(__MODULE__, {:notify, source})
  end

  @impl true
  def handle_cast({:notify, source}, %{twilio_phone_number: twilio_phone_number} = state) do
    Logger.info("#{@prefix} notifying about #{source}...")

    {:noreply, state}
  end
end
