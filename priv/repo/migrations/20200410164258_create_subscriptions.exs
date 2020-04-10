defmodule Unixbot.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add(:channel_id, :bigint, null: false)
      add(:cron, :map, null: false)
      add(:subreddit, :string, null: false)

      timestamps()
    end
  end
end
