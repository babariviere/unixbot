import Config

config :unixbot, prefix: "~"

import_config "#{Mix.env()}.exs"
