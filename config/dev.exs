import Config

config :logger, :console, format: "[$level] $message\n"

config :logger, level: :debug

config :nostrum,
  num_shards: :auto

import_config "dev.secrets.exs"
