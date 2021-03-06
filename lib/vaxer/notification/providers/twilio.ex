defmodule Vaxer.Notification.Providers.Twilio do
  use GenServer
  require Logger
  alias ExTwilio

  @prefix "Twilio notifier"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(
        twilio_phone_number: twilio_phone_number,
        notification_phone_numbers: notification_phone_numbers
      ) do
    Logger.info(
      "Starting #{@prefix} with phone number #{twilio_phone_number} and notification phone numbers: #{
        Enum.join(notification_phone_numbers, ", ")
      }..."
    )

    {:ok,
     %{
       twilio_phone_number: twilio_phone_number,
       notification_phone_numbers: notification_phone_numbers,
       last_message_source: nil
     }}
  end

  def notify(source, url) do
    GenServer.cast(__MODULE__, {:notify, source, url})
  end

  @impl true
  def handle_cast(
        {:notify, source, url},
        %{
          twilio_phone_number: twilio_phone_number,
          notification_phone_numbers: notification_phone_numbers,
          last_message_source: last_message_source
        } = state
      ) do
    if last_message_source == source do
      Logger.info("#{@prefix} skipping duplicate notification about #{source}...")
    else
      Logger.info("#{@prefix} notifying about #{source}...")

      Enum.each(notification_phone_numbers, fn target_number ->
        Logger.debug("#{@prefix} notifying #{target_number} about #{source}...")

        body = "Found vaccines at #{source}\n\nLink: #{url}"

        ExTwilio.Message.create(to: target_number, from: twilio_phone_number, body: body)
      end)
    end

    new_state = %{state | last_message_source: source}
    {:noreply, new_state}
  end
end
