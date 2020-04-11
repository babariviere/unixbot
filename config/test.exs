import Config

config :logger, :console, format: "[$level] $message\n"

config :logger, level: :debug

config :nostrum,
  num_shards: :auto

config :unixbot, Unixbot.Repo,
  database: "unixbot_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

import_config "test.secrets.exs"
