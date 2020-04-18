defmodule Reddit.Post do
  @moduledoc """
  A Reddit post without it's comments.
  """

  defstruct [
    :id,
    :title,
    :author,
    :url,
    :permalink,
    :thumbnail,
    :score,
    :ups,
    :downs,
    :is_self,
    :is_video
  ]

  @expected_fields ~w(id title author url permalink thumbnail score ups downs is_self is_video)

  @typedoc "Author username."
  @type author :: String.t()

  @typedoc "URL to media."
  @type url :: String.t()

  @typedoc "Permalink to post. Format: /r/_subreddit_/comments/_id_/"
  @type permalink :: String.t()

  @type t() :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          author: author,
          url: url | nil,
          permalink: permalink,
          thumbnail: url | nil,
          score: integer(),
          ups: integer(),
          downs: integer(),
          is_self: boolean(),
          is_video: boolean()
        }

  @doc """
  Convert JSON to Post struct.
  """
  @spec from_json(map()) :: t()
  def from_json(%{"data" => data}) do
    data =
      data
      |> Map.take(@expected_fields)
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)

    struct(__MODULE__, data)
  end
end
