defmodule Unixbot.Subscription do
  @moduledoc """
  A subscription from a discord channel to a subreddit.
  """

  use Ecto.Schema

  schema "subscriptions" do
    field(:channel_id, :id)
    field(:cron, Crontab.CronExpression.Ecto.Type)
    field(:subreddit, :string)

    timestamps()
  end
end
