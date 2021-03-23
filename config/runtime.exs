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

      _ -> value
    end
  end
end

config :vaxer,
  delay: get_env_var.("DELAY", :int, 10000),
  notification_phone_numbers: get_env_var.("NOTIFICATION_PHONE_NUMBERS", :list, :none),
  phone_number: get_env_var.("TWILIO_PHONE_NUMBER", nil, :none)

config :ex_twilio,
  account_sid: get_env_var.("TWILIO_ACCOUNT_SID", nil, :none),
  auth_token: get_env_var.("TWILIO_AUTH_TOKEN", nil, :none)
