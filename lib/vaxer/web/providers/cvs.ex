defmodule Vaxer.Web.Providers.CVS do
  use GenServer
  require Logger
  alias Wallaby
  alias Wallaby.{Browser, Query, Element}
  alias Vaxer.Notification.Providers.Twilio

  @url "https://www.cvs.com/immunizations/covid-19-vaccine"
  @prefix "CVS provider"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init([delay: delay]) do
    Logger.info("Starting #{@prefix} with delay #{delay}...")

    {:ok, session} = Wallaby.start_session()
    timer = create_check_timer(delay)

    {:ok, %{session: session, timer: timer, delay: delay}}
  end

  @impl true
  def handle_info(:check, %{session: session, delay: delay} = state) do
    Logger.debug("#{@prefix} checking...")

    result = check(session)
    if result do
      Logger.info("#{@prefix} found vaccines!")
      Twilio.notify("CVS", @url)
    else
      Logger.debug("#{@prefix} did not find any vaccines")
    end

    timer = create_check_timer(delay)

    new_state = %{state | timer: timer}

    {:noreply, new_state}
  end

  defp create_check_timer(delay) do
    Process.send_after(self(), :check, delay)
  end

  defp check(session) do
    session
    |> Browser.visit(@url)
    |> Browser.click(Query.link("Massachusetts"))
    |> Browser.all(Query.css("span.status"))
    |> Enum.any?(fn element ->
      text = Element.text(element)
      !String.contains?(text, "Fully Booked")
    end)
  end
end
