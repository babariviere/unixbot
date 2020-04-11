defmodule Unixbot.Command.Subscribe do
  @moduledoc """
  Subscribe a new subscription in the given channel.

  Usage: subscribe <subreddit> <time>

  # Parameters

  subreddit - the name of the subreddit to subscribe to
  time - a time to get post every day. format: <hour>h<minute>
  """

  use Unixbot.Command

  @admin Application.get_env(:unixbot, :admin_id)

  alias Unixbot.Subscription

  @impl true
  def short_desc(), do: "Subscribe to a subreddit. (admin only)"

  @impl true
  def desc(),
    do: """
    #{short_desc()}

    Usage: subscribe <subreddit> <time>

    # Parameters

    subreddit - the name of the subreddit to subscribe to
    time - a time to get post every day. format: <hour>h<minute>
    """

  @impl true
  def execute(%Arguments{values: [subreddit, time]}, %Message{author: %User{id: @admin}} = msg) do
    [hour, minute] =
      time
      |> String.split("h")
      |> Enum.map(&String.to_integer/1)
      |> Enum.take(2)

    cron = %Crontab.CronExpression{
      hour: [hour],
      minute: [minute]
    }

    try do
      %Subscription{}
      |> Subscription.changeset(%{
        channel_id: msg.channel_id,
        subreddit: subreddit,
        cron: cron
      })
      |> Unixbot.Repo.insert!()
      |> Subscription.schedule()
    rescue
      _ ->
        Nostrum.Api.create_message!(
          msg.channel_id,
          content: "An error occured, I cannot create subscription."
        )
    else
      _ ->
        Nostrum.Api.create_message!(
          msg.channel_id,
          content: "Created subscription for subreddit #{subreddit}, every day at #{time}."
        )
    end
  end

  def execute(_args, %Message{author: %User{id: @admin}} = msg) do
    Nostrum.Api.create_message!(
      msg.channel_id,
      content: "Wrong number of arguments. Usage: subscribe <subreddit> <hour:minute>"
    )
  end

  def execute(_args, msg) do
    Nostrum.Api.create_message!(
      msg.channel_id,
      content: "You are not authorized to do this action."
    )
  end
end
