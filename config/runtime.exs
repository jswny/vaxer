import Config

app_name = :vaxer

get_env_var = fn var_name, default ->
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
    value
  end
end

config :vaxer,
  delay: get_env_var.("DELAY", 10000)
