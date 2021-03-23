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
      _ -> value
    end
  end
end

config :vaxer,
  delay: get_env_var.("DELAY", :int, 10000)

config :ex_twilio,
  account_sid: get_env_var.("TWILIO_ACCOUNT_SID", nil, nil),
  auth_token: get_env_var.("TWILIO_AUTH_TOKEN", nil, nil)
