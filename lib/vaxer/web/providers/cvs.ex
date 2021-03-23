defmodule Vaxer.Web.Providers.CVS do
  use GenServer
  require Logger
  alias Wallaby
  alias Wallaby.{Browser, Query, Element}

  @url "https://www.cvs.com/immunizations/covid-19-vaccine"
  @prefix "CVS provider"

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], [])
  end

  @impl true
  def init(_opts) do
    Logger.info("Starting CVS provider...")

    {:ok, session} = Wallaby.start_session()
    timer_ref = Process.send_after(self(), :check, 1000)

    {:ok, %{session: session, timer: timer_ref}}
  end

  @impl true
  def handle_info(:check, %{session: session} = state) do
    Logger.debug("#{@prefix} checking...")

    result = check(session)
    if result do
      Logger.info("#{@prefix} found vaccines!")
    else
      Logger.debug("#{@prefix} did not find any vaccines")
    end

    {:noreply, state}
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
