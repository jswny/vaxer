defmodule Vaxer.Location do
  use GenServer
  require Logger

  @prefix "Location provider"
  @state_abbreviations_to_names %{
    "AL" => "Alabama",
    "AK" => "Alaska",
    "AS" => "American Samoa",
    "AZ" => "Arizona",
    "AR" => "Arkansas",
    "CA" => "California",
    "CO" => "Colorado",
    "CT" => "Connecticut",
    "DE" => "Delaware",
    "DC" => "District Of Columbia",
    "FM" => "Federated States Of Micronesia",
    "FL" => "Florida",
    "GA" => "Georgia",
    "GU" => "Guam",
    "HI" => "Hawaii",
    "ID" => "Idaho",
    "IL" => "Illinois",
    "IN" => "Indiana",
    "IA" => "Iowa",
    "KS" => "Kansas",
    "KY" => "Kentucky",
    "LA" => "Louisiana",
    "ME" => "Maine",
    "MH" => "Marshall Islands",
    "MD" => "Maryland",
    "MA" => "Massachusetts",
    "MI" => "Michigan",
    "MN" => "Minnesota",
    "MS" => "Mississippi",
    "MO" => "Missouri",
    "MT" => "Montana",
    "NE" => "Nebraska",
    "NV" => "Nevada",
    "NH" => "New Hampshire",
    "NJ" => "New Jersey",
    "NM" => "New Mexico",
    "NY" => "New York",
    "NC" => "North Carolina",
    "ND" => "North Dakota",
    "MP" => "Northern Mariana Islands",
    "OH" => "Ohio",
    "OK" => "Oklahoma",
    "OR" => "Oregon",
    "PW" => "Palau",
    "PA" => "Pennsylvania",
    "PR" => "Puerto Rico",
    "RI" => "Rhode Island",
    "SC" => "South Carolina",
    "SD" => "South Dakota",
    "TN" => "Tennessee",
    "TX" => "Texas",
    "UT" => "Utah",
    "VT" => "Vermont",
    "VI" => "Virgin Islands",
    "VA" => "Virginia",
    "WA" => "Washington",
    "WV" => "West Virginia",
    "WI" => "Wisconsin",
    "WY" => "Wyoming"
  }

  NimbleCSV.define(ZipDistancesParser, [])

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_state_name_from_abbreviation(abbreviation) do
    name = Map.get(@state_abbreviations_to_names, abbreviation, nil)

    if name == nil do
      {:error, "invalid state abbreviation"}
    else
      {:ok, name}
    end
  end

  @impl true
  def init(
        zip_code: zip_code,
        max_distance: max_distance,
        zip_distances_path: zip_distances_path,
        cvs_zip_codes_path: cvs_zip_codes_path
      ) do
    Logger.info("Starting #{prefix_with_zip_code(zip_code, max_distance)}...")

    if zip_code == nil do
      Logger.info("#{prefix_with_zip_code(zip_code, max_distance)} bypassing ZIP code checks...")

      {:ok, %{bypass: true, max_distance: max_distance, zip_distances: %{}, cvs_zip_codes: %{}}}
    else
      Logger.debug("#{prefix_with_zip_code(zip_code, max_distance)} loading ZIP distances...")

      zip_distances = parse_zip_distances(zip_distances_path, zip_code, max_distance)

      Logger.debug(
        "#{prefix_with_zip_code(zip_code, max_distance)} loaded #{Enum.count(zip_distances)} ZIP distances!"
      )

      Logger.debug("#{prefix_with_zip_code(zip_code, max_distance)} loading CVS ZIP codes...")

      cvs_zip_codes = parse_cvs_zip_codes(cvs_zip_codes_path)

      Logger.debug(
        "#{prefix_with_zip_code(zip_code, max_distance)} loaded #{Enum.count(cvs_zip_codes)} CVS ZIP codes!"
      )

      {:ok,
       %{
         bypass: false,
         max_distance: max_distance,
         zip_distances: zip_distances,
         cvs_zip_codes: cvs_zip_codes
       }}
    end
  end

  def cvs_location_within_distance?(location) do
    GenServer.call(__MODULE__, {:cvs_location_within_distance, location})
  end

  def max_distance() do
    GenServer.call(__MODULE__, :max_distance)
  end

  @impl true
  def handle_call(
        {:cvs_location_within_distance, location},
        _from,
        %{
          bypass: bypass,
          max_distance: max_distance,
          zip_distances: zip_distances,
          cvs_zip_codes: cvs_zip_codes
        } = state
      ) do
    if bypass do
      {:reply, true, state}
    else
      zip_code = Map.get(cvs_zip_codes, String.downcase(location))
      {:reply, zip_within_distance?(zip_distances, zip_code, max_distance), state}
    end
  end

  @impl true
  def handle_call(:max_distance, _from, %{max_distance: max_distance} = state) do
    {:reply, max_distance, state}
  end

  defp parse_zip_distances(zip_distances_path, zip_code, max_distance) do
    zip_distances_path
    |> File.stream!(read_ahead: 100_000)
    |> ZipDistancesParser.parse_stream()
    |> Stream.filter(fn [zip1, _zip2, _distance] -> zip1 == zip_code end)
    |> Stream.map(fn [_zip1, zip2, distance] ->
      {:binary.copy(zip2), String.to_float(distance)}
    end)
    |> Stream.filter(fn {_zip2, distance} -> distance <= max_distance end)
    |> Enum.into(%{})
  end

  defp parse_cvs_zip_codes(cvs_zips_path) do
    cvs_zips_path
    |> File.stream!(read_ahead: 100_000)
    |> ZipDistancesParser.parse_stream()
    |> Stream.map(fn [city, state, zip] ->
      location = "#{:binary.copy(city)}, #{:binary.copy(state)}" |> String.downcase()
      {location, :binary.copy(zip)}
    end)
    |> Enum.into(%{})
  end

  defp zip_within_distance?(zip_distances, to_zip, max_distance) do
    distance = Map.get(zip_distances, to_zip)

    if distance != nil && distance <= max_distance do
      true
    else
      false
    end
  end

  defp prefix_with_zip_code(zip_code, max_distance) do
    if zip_code == nil do
      "#{@prefix}"
    else
      "#{@prefix} for ZIP code #{zip_code} with maximum distance #{max_distance}"
    end
  end
end
