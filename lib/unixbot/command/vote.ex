defmodule Unixbot.Command.Vote do
  @moduledoc """
  Command to vote for a post.
  """

  use Unixbot.Command

  alias Unixbot.Repo
  alias Unixbot.ChannelCache
  alias Unixbot.Post
  alias Unixbot.Post.Vote

  @impl true
  def short_desc(), do: "Vote for a post."

  @impl true
  def desc(),
    do: """
    #{short_desc()}

    Usage: vote <score> [comment] [id:post_id]

    Score is a value between 0 and 100.
    An optional comment can be given to provide more context for the score.

    # Example

    Vote for last post: `vote 15 This setup is ugly.`

    Vote for a specific post: `vote 100 Best post ever. id:g3nps0`
    """

  @impl true
  def execute(
        %Arguments{values: [score | comment], params: params},
        %Message{id: message_id, channel_id: channel_id, author: %User{id: user_id}}
      ) do
    post =
      case Map.get(params, "id") do
        nil -> ChannelCache.last_post(channel_id)
        id -> Repo.get_by(Post, %{channel_id: channel_id, reddit_post_id: id})
      end

    if post do
      comment =
        case comment do
          [] -> nil
          comment -> Enum.join(comment, " ")
        end

      vote(score, comment, post.id, channel_id, message_id, user_id)
    else
      Api.create_message!(channel_id, content: "It looks like there is no post in this channel.")
    end
  end

  defp vote(score, comment, post_id, channel_id, message_id, user_id) do
    vote =
      %Vote{}
      |> Vote.changeset(%{
        post_id: post_id,
        discord_user_id: user_id,
        score: score,
        comment: comment
      })
      |> Repo.insert(
        on_conflict: {:replace, [:score, :comment, :updated_at]},
        conflict_target: [:post_id, :discord_user_id]
      )

    case vote do
      {:ok, _vote} ->
        emoji = random_emote()
        Api.create_reaction!(channel_id, message_id, emoji)

      {:error, changeset} ->
        message = format_errors(changeset)

        Api.create_message!(channel_id,
          content: "I can't register your vote because of the following errors:\n#{message}"
        )
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      "- #{acc}#{k} #{hd(v)}\n"
    end)
  end

  defp random_emote do
    alias Nostrum.Struct.Emoji

    emotes = [
      %Emoji{id: 616_348_820_158_152_764, name: "monkeyEuhh"},
      %Emoji{id: 288_737_060_146_249_728, name: "soral"},
      %Emoji{id: 585_751_521_199_915_008, name: "soralBof"},
      %Emoji{id: 652_424_828_413_804_554, name: "RockNotBad"},
      %Emoji{id: 613_804_706_984_099_916, name: "etchebestOof"},
      %Emoji{id: 587_655_590_344_654_849, name: "kemarMind"}
    ]

    Enum.random(emotes)
  end
end
