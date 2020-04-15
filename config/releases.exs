import Config

config :nostrum,
  token: System.get_env("DISCORD_TOKEN")

config :unixbot, :reddit,
  username: System.get_env("REDDIT_USERNAME"),
  password: System.get_env("REDDIT_PASSWORD"),
  client_id: System.get_env("REDDIT_CLIENT_ID"),
  client_secret: System.get_env("REDDIT_CLIENT_SECRET")

config :unixbot, admin_id: String.to_integer(System.get_env("DISCORD_ADMIN_ID"))

config :unixbot, Unixbot.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: 10
