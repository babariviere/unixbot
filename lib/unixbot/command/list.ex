defmodule Unixbot.Command.List do
  @moduledoc """
  List values for a given commands. (worst description ever)
  """

  use Unixbot.Command

  import Ecto.Query, only: [from: 2]
  alias Unixbot.Repo

  @impl true
  def short_desc(), do: "List values from sources."

  @impl true
  def desc(),
    do: """
    #{short_desc()}

    # Sources

    subscriptions - this will list all subscriptions for a given channel.
    """

  @impl true
  def execute(%Arguments{values: ["subscriptions"]}, %Message{channel_id: channel_id}) do
    query =
      from(s in Unixbot.Subscription,
        where: s.channel_id == ^channel_id,
        select: {s.subreddit, s.cron}
      )

    embed =
      Repo.all(query)
      |> Enum.reduce(%Embed{}, fn {sub, cron}, embed ->
        Embed.put_field(
          embed,
          sub,
          "Every day at #{format_cron(cron)}"
        )
      end)
      |> Embed.put_title("Subscriptions")
      |> Embed.put_description("List of all subscriptions from this channel")

    Api.create_message!(channel_id, embed: embed)
  end

  @impl true
  def execute(_, msg) do
    Unixbot.Command.Help.execute(%Arguments{values: ["list"]}, msg)
  end

  defp format_cron(cron) do
    hour =
      cron.hour
      |> hd
      |> to_string()
      |> String.pad_leading(2, "0")

    minute =
      cron.minute
      |> hd
      |> to_string()
      |> String.pad_leading(2, "0")

    "#{hour}h#{minute}"
  end
end
