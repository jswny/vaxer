defmodule Vaxer.Web.Providers.CVS do
  use GenServer
  require Logger

  alias Wallaby

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
end
