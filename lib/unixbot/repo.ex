defmodule Unixbot.Repo do
  use Ecto.Repo,
    otp_app: :unixbot,
    adapter: Ecto.Adapters.Postgres
end
