defmodule Unixbot.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:channel_id, :bigint, null: false)
      add(:permalink, :string, null: false)
      add(:reddit_post_id, :string, null: false)

      timestamps()
    end

    create(unique_index(:posts, [:channel_id, :reddit_post_id]))
  end
end
