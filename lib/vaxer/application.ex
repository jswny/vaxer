defmodule Vaxer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Vaxer.{Notification, Web, Location}

  @impl true
  def start(_type, _args) do
    zip_code =
      Application.get_application(__MODULE__)
      |> Application.get_env(:zip_code)

    max_distance =
      Application.get_application(__MODULE__)
      |> Application.get_env(:max_distance)

    zip_distances_path =
      Application.get_application(__MODULE__)
      |> Application.get_env(:zip_distances_path)

    cvs_zip_codes_path =
      Application.get_application(__MODULE__)
      |> Application.get_env(:cvs_zip_codes_path)

    children = [
      # Starts a worker by calling: Vaxer.Worker.start_link(arg)
      # {Vaxer.Worker, arg}
      {Location,
       [
         zip_code: zip_code,
         max_distance: max_distance,
         zip_distances_path: zip_distances_path,
         cvs_zip_codes_path: cvs_zip_codes_path
       ]},
      Notification.Supervisor,
      Web.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vaxer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
