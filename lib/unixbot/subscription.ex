defmodule Unixbot.Subscription do
  @moduledoc """
  A subscription from a discord channel to a subreddit.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Unixbot.Scheduler
  alias Unixbot.Scheduler.Job
  alias Unixbot.Post
  alias Unixbot.Repo

  alias Nostrum.Struct.Embed

  @type t() :: %__MODULE__{
          channel_id: non_neg_integer(),
          cron: Crontab.CronExpression.t(),
          subreddit: String.t()
        }

  schema "subscriptions" do
    field(:channel_id, :id)
    field(:cron, Crontab.CronExpression.Ecto.Type)
    field(:subreddit, :string)

    timestamps()
  end

  @doc false
  def changeset(sub, attrs) do
    sub
    |> cast(attrs, [:channel_id, :cron, :subreddit])
    |> validate_required([:channel_id, :cron, :subreddit])
    |> validate_number(:channel_id, greater_than: 0)
    |> validate_length(:subreddit, min: 3, max: 20)
  end

  @spec schedule_name(t()) :: String.t()
  defp schedule_name(sub) do
    list_to_str = fn x -> Enum.map(x, &to_string/1) |> Enum.join(".") end

    hour = list_to_str.(sub.cron.hour)
    minute = list_to_str.(sub.cron.minute)

    "#{sub.channel_id}_#{sub.subreddit}_#{hour}_#{minute}"
  end

  @spec schedule_func(t()) :: function()
  defp schedule_func(sub) do
    fn ->
      with {:ok, %Reddit.Listing{children: [post]}} <-
             Reddit.subreddit(sub.subreddit, :top, limit: 1, t: :day) do
        put_media = fn
          embed, %Reddit.Post{url: url, is_video: true} ->
            Embed.put_video(embed, url)

          embed, %Reddit.Post{url: url, is_self: false} ->
            Embed.put_image(embed, url)

          embed, _ ->
            embed
        end

        msg =
          %Embed{}
          |> Embed.put_title(post.title)
          |> Embed.put_description("Here is your daily porn my child.")
          |> Embed.put_field("ID", to_string(post.id), true)
          |> Embed.put_field("Score", to_string(post.score), true)
          |> Embed.put_color(431_948)
          |> Embed.put_url("https://reddit.com#{post.permalink}")
          |> put_media.(post)
          |> Embed.put_author("u/#{post.author}", "https://reddit.com/u/#{post.author}", nil)

        Nostrum.Api.create_message!(sub.channel_id, embed: msg)

        post =
          case Repo.get_by(Post, %{channel_id: sub.channel_id, reddit_post_id: post.id}) do
            nil ->
              %Post{}
              |> Post.changeset(%{
                channel_id: sub.channel_id,
                permalink: post.permalink,
                reddit_post_id: post.id
              })
              |> Repo.insert()

            post ->
              {:ok, post}
          end

        with {:ok, post} <- post do
          Unixbot.ChannelCache.new_post(post)
        end
      end
    end
  end

  @doc """
  Schedule subscriptions using `Unixbot.Scheduler`.
  """
  @spec schedule(t()) :: :ok
  def schedule(sub) do
    name = schedule_name(sub)
    func = schedule_func(sub)

    job = %Job{
      name: name,
      expr: sub.cron,
      func: func
    }

    Scheduler.register(job)
  end
end
