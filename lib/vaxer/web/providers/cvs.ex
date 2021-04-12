defmodule Vaxer.Web.Providers.CVS do
  use GenServer
  require Logger
  alias Wallaby
  alias Wallaby.{Browser, Query, Element}
  alias Vaxer.Notification.Providers.Twilio
  alias Vaxer.Location

  @url "https://www.cvs.com/immunizations/covid-19-vaccine"
  @prefix "CVS provider"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(selenium_url: selenium_url, delay: delay, state_abbreviation: state_abbreviation) do
    {:ok, state_name} = Vaxer.Location.get_state_name_from_abbreviation(state_abbreviation)

    Logger.info("Starting #{prefix_with_state(state_name)} with delay #{delay} ms...")

    timer = inital_check_delay(delay)

    {:ok,
     %{
       selenium_url: selenium_url,
       timer: timer,
       delay: delay,
       state_name: state_name,
       state_abbreviation: state_abbreviation
     }}
  end

  @impl true
  def handle_info(
        :check,
        %{
          selenium_url: selenium_url,
          timer: timer,
          delay: delay,
          state_name: state_name,
          state_abbreviation: state_abbreviation
        } = state
      ) do
    Logger.debug("#{prefix_with_state(state_name)} checking...")

    Process.cancel_timer(timer)

    locations = check_with_new_session(selenium_url, state_name)

    if Enum.count(locations) > 0 do
      Logger.debug(
        "#{prefix_with_state(state_name)} found vaccines in state in #{
          locations_to_cities(locations, state_abbreviation, false)
        }!"
      )
    end

    locations_and_zips_within_distance =
      locations
      |> Enum.map(fn location -> {location, Location.cvs_location_within_distance?(location)} end)
      |> Enum.filter(fn {_location, zip} -> zip != nil end)

    distance = Location.max_distance()

    if Enum.count(locations_and_zips_within_distance) > 0 do
      cities_inline =
        locations_to_cities_and_zips(locations_and_zips_within_distance, state_abbreviation)

      cities =
        locations_to_cities_and_zips(locations_and_zips_within_distance, state_abbreviation, true)

      Logger.info(
        "#{prefix_with_state(state_name)} found vaccines within #{distance} miles in #{
          cities_inline
        }!"
      )

      Twilio.notify("CVS in #{state_name} in:\n\n#{cities}", @url)
    else
      Logger.debug(
        "#{prefix_with_state(state_name)} did not find any vaccines within #{distance} miles"
      )
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
    locations = check(session, state_name)
    Wallaby.end_session(session)

    locations
  end

  defp check(session, state_name) do
    session
    |> Browser.visit(@url)
    |> Browser.click(Query.link(state_name))
    |> Browser.all(Query.css("div.covid-status tbody tr"))
    |> Enum.map(fn tr ->
      location =
        tr
        |> Browser.find(Query.css("span.city"))
        |> Element.text()

      status =
        tr
        |> Browser.find(Query.css("span.status"))
        |> Element.text()
        |> String.contains?("Fully Booked")

      status = !status

      {location, status}
    end)
    |> Enum.filter(fn {_location, status} -> status == true end)
    |> Enum.map(fn {location, _status} -> location end)
  end

  defp prefix_with_state(state) do
    "#{@prefix} for state #{state}"
  end

  defp locations_to_cities(locations, state_abbreviation, multiline? \\ false) do
    separator =
      if multiline? do
        "\n"
      else
        ", "
      end

    locations
    |> Enum.map(fn location -> String.replace(location, ", #{state_abbreviation}", "") end)
    |> Enum.join(separator)
  end

  defp locations_to_cities_and_zips(locations, state_abbreviation, multiline? \\ false) do
    separator =
      if multiline? do
        "\n"
      else
        ", "
      end

    locations
    |> Enum.map(fn {location, zip} ->
      city = String.replace(location, ", #{state_abbreviation}", "")

      zip =
        if zip != :bypass do
          " (#{zip})"
        else
          ""
        end

      "#{city}#{zip}"
    end)
    |> Enum.join(separator)
  end
end
