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
  def init([selenium_url: selenium_url, delay: delay, state_abbreviation: state_abbreviation]) do
    Logger.info("Starting #{@prefix} for state #{state_abbreviation} with delay #{delay} ms...")

    timer = inital_check_delay(delay)

    {:ok, state_name} = Vaxer.Location.get_state_name_from_abbreviation(state_abbreviation)

    {:ok, %{selenium_url: selenium_url, timer: timer, delay: delay, state_name: state_name}}
  end

  @impl true
  def handle_info(:check, %{selenium_url: selenium_url, timer: timer, delay: delay, state_name: state_name} = state) do
    Logger.debug("#{@prefix} checking...")

    Process.cancel_timer(timer)

    result = check_with_new_session(selenium_url, state_name)

    if result do
      Logger.info("#{@prefix} found vaccines!")
      Twilio.notify("CVS", @url)
    else
      Logger.debug("#{@prefix} did not find any vaccines")
    end

    timer = check_after_delay(delay)

    new_state = %{state | timer: timer}

    {:noreply, new_state}
  end

  @impl true
  def terminate(_reason, %{timer: timer}) do
    Process.cancel_timer(timer)
  end

  defp check_after_delay(delay) do
    Process.send_after(self(), :check, delay)
  end

  defp start_session(selenium_url) do
    {:ok, session} =
      if selenium_url != nil do
        Wallaby.start_session(remote_url: selenium_url, capabilities: %{browserName: "chrome"})
      else
        Wallaby.start_session()
      end

    session
  end

  defp inital_check_delay(delay) do
    one_minute = 60000

    initial_check_delay =
      if delay < one_minute do
        delay
      else
        one_minute
      end

    check_after_delay(initial_check_delay)
  end

  defp check_with_new_session(selenium_url, state_name) do
    session = start_session(selenium_url)
    result = check(session, state_name)
    Wallaby.end_session(session)

    result
  end

  defp check(session, state_name) do
    session
    |> Browser.visit(@url)
    |> Browser.click(Query.link(state_name))
    |> Browser.all(Query.css("span.status"))
    |> Enum.any?(fn element ->
      text = Element.text(element)
      !String.contains?(text, "Fully Booked")
    end)
  end
end
