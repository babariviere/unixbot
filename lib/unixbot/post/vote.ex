defmodule Unixbot.Post.Vote do
  @moduledoc """
  An user vote on a Reddit Post.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          post_id: integer(),
          discord_user_id: non_neg_integer(),
          score: non_neg_integer(),
          comment: String.t() | nil
        }

  schema "votes" do
    field(:discord_user_id, :id)
    field(:score, :integer)
    field(:comment, :string)

    belongs_to(:post, Unixbot.Post)

    timestamps()
  end

  @doc false
  def changeset(sub, attrs) do
    sub
    |> cast(attrs, [:post_id, :discord_user_id, :score, :comment])
    |> validate_required([:post_id, :discord_user_id, :score])
    |> validate_number(:score, greater_than_or_equal_to: 0)
    |> validate_number(:score, less_than_or_equal_to: 100)
    |> validate_number(:post_id, greater_than: 0)
    |> validate_number(:discord_user_id, greater_than: 0)
    |> foreign_key_constraint(:post_id)
  end
end
