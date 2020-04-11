defmodule Unixbot.Command.Help do
  @moduledoc """
  Show help information for a command.
  """

  use Unixbot.Command

  @impl true
  def short_desc(), do: "Show this help message."

  @impl true
  def desc(), do: short_desc()

  @impl true
  def execute(%Arguments{values: []}, msg) do
    embed =
      %Embed{}
      |> Embed.put_title("Help")
      |> Embed.put_description("List of all available commands.")

    embed =
      Unixbot.Consumer.commands()
      |> Enum.reduce(embed, fn {name, mod}, embed ->
        Embed.put_field(embed, name, mod.short_desc())
      end)

    Api.create_message!(msg.channel_id, embed: embed)
  end

  def execute(%Arguments{values: [cmd]}, msg) do
    embed =
      %Embed{}
      |> Embed.put_title("Help: #{cmd}")

    embed =
      case Map.get(Unixbot.Consumer.commands(), cmd) do
        c when c != nil ->
          Embed.put_description(embed, c.desc())

        nil ->
          Embed.put_description(embed, "Command is not available.")
      end

    Api.create_message!(msg.channel_id, embed: embed)
  end
end
