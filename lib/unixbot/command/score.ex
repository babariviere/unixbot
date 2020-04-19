defmodule Unixbot.Command.Score do
  @moduledoc """
  Get the score for a post.
  """

  use Unixbot.Command

  alias Unixbot.Repo
  alias Unixbot.ChannelCache
  alias Unixbot.Post
  alias Unixbot.Post.Vote

  import Ecto.Query, only: [from: 2]

  @impl true
  def short_desc(), do: "Get score for a post."

  @impl true
  def desc(),
    do: """
    #{short_desc()}

    Usage: score [post_id]
    """

  @impl true
  def execute(%Arguments{values: []}, %Message{channel_id: channel_id}) do
    post = ChannelCache.last_post(channel_id)

    case post do
      nil ->
        Api.create_message!(channel_id, content: "It looks like there is no post in this channel.")

      post ->
        score(post)
    end
  end

  @impl true
  def execute(%Arguments{values: [post_id]}, %Message{channel_id: channel_id}) do
    post = Repo.get_by(Post, reddit_post_id: post_id)

    case post do
      nil ->
        Api.create_message!(channel_id, content: "Post #{post_id} can't be found.")

      post ->
        score(post)
    end
  end

  defp score(post) do
    query =
      from(v in Vote,
        where: v.post_id == ^post.id
      )

    votes = Repo.all(query)

    {total, count} =
      Enum.reduce(votes, {0, 0}, fn x, {total, count} ->
        {total + x.score, count + 1}
      end)

    avg = round(total / count)

    # TODO: add commentary on score.
    Api.create_message!(post.channel_id, content: "This post has a score of #{avg}.")
  end
end
