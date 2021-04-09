import Config

app_name = :vaxer

get_env_var = fn var_name, type, default ->
  value = System.get_env(var_name)

  if value == nil || value == "" do
    if default != :none do
      default
    else
      raise """
      Environment variable #{var_name} is missing!
      """
    end
  else
    case type do
      :int ->
        {value, _} = Integer.parse(value)
        value

      :list ->
        String.split(value, ",")

      _ ->
        value
    end
  end
end

get_driver = fn value ->
  case value do
    "selenium" -> Wallaby.Selenium
    _ -> Wallaby.Chrome
  end
end

driver = get_driver.(get_env_var.("DRIVER", nil, nil))

config :vaxer,
  delay: get_env_var.("DELAY", :int, 600_000),
  state_abbreviation: get_env_var.("STATE_ABBREVIATION", nil, :none),
  notification_phone_numbers: get_env_var.("NOTIFICATION_PHONE_NUMBERS", :list, :none),
  twilio_phone_number: get_env_var.("TWILIO_PHONE_NUMBER", nil, :none),
  zip_code: get_env_var.("ZIP_CODE", nil, nil),
  zip_distances_path: get_env_var.("ZIP_DISTANCES_PATH", nil, "data/zips.csv"),
  cvs_zip_codes_path: get_env_var.("CVS_ZIP_CODES_PATH", nil, "data/cvs_zips.csv")

config :wallaby,
  driver: get_driver.(get_env_var.("DRIVER", nil, nil))

if driver == Wallaby.Selenium do
  config :vaxer,
    selenium_url: get_env_var.("SELENIUM_URL", nil, "http://localhost:4444/")
end

config :ex_twilio,
  account_sid: get_env_var.("TWILIO_ACCOUNT_SID", nil, :none),
  auth_token: get_env_var.("TWILIO_AUTH_TOKEN", nil, :none)
