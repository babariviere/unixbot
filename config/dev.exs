import Config

config :logger, :console, format: "[$level] $message\n"

config :logger, level: :debug

config :nostrum,
  num_shards: :auto

config :unixbot, Unixbot.Repo,
  database: "unixbot_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

import_config "dev.secrets.exs"
