defmodule Unixbot.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add(:post_id, references(:posts), null: false)
      add(:discord_user_id, :bigint, null: false)
      add(:score, :int, null: false)
      add(:comment, :string)

      timestamps()
    end

    create(unique_index(:votes, [:post_id, :discord_user_id]))
    create(constraint(:votes, :score_between_0_and_100, check: "score >= 0 AND score <= 100"))
  end
end
