import Config

config :unixbot, prefix: "~"

config :logger,
  compile_time_purge_matching: [
    # Nostrum logs are useless and spammy
    [application: :nostrum]
  ]

import_config "#{Mix.env()}.exs"
