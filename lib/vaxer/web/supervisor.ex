defmodule Vaxer.Web.Supervisor do
  use Supervisor
  require Logger
  alias Vaxer.Web.Providers.{CVS}

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    selenium_url =
      Application.get_application(__MODULE__)
      |> Application.get_env(:selenium_url)

    delay =
      Application.get_application(__MODULE__)
      |> Application.get_env(:delay)

    state_abbreviation =
      Application.get_application(__MODULE__)
      |> Application.get_env(:state_abbreviation)

    children = [
      {CVS, selenium_url: selenium_url, delay: delay, state_abbreviation: state_abbreviation}
    ]

    selenium_info =
      if selenium_url != nil do
        " with Selenium at #{selenium_url}"
      else
        ""
      end

    Logger.info("Starting web supervisor...#{selenium_info}")

    Supervisor.init(children, strategy: :one_for_one)
  end
end
