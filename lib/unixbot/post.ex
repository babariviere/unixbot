defmodule Unixbot.Post do
  @moduledoc """
  A reddit post basic information.

  Only used to link votes to it.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          channel_id: non_neg_integer(),
          permalink: String.t(),
          reddit_post_id: String.t()
        }

  schema "posts" do
    field(:channel_id, :id)
    field(:permalink, :string)
    field(:reddit_post_id, :string)
    has_many(:votes, Unixbot.Post.Vote)

    timestamps()
  end

  @doc false
  def changeset(sub, attrs) do
    sub
    |> cast(attrs, [:channel_id, :permalink, :reddit_post_id])
    |> validate_required([:channel_id, :permalink, :reddit_post_id])
    |> validate_format(:permalink, ~r/r\/.*/)
    |> validate_number(:channel_id, greater_than: 0)
    |> validate_number(:reddit_post_id, greater_than: 0)
    |> unique_constraint(:reddit_post_id, name: :posts_channel_id_reddit_post_id_index)
  end
end
