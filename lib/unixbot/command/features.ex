defmodule Unixbot.Command.Features do
  @moduledoc """
  List all features that will be implemented. (will be removed in the future)
  """

  use Unixbot.Command

  @impl true
  def execute(_args, msg) do
    embed =
      %Embed{}
      |> Embed.put_title("Features")
      |> Embed.put_description("List of all features that are implemented / planned")

    features = [
      {"Daily top posts", "done"},
      {"Utilities", "doing"},
      {"Vote system", "next"},
      {"Classement", "todo"},
      {"Extract configuration from comments", "todo"},
      {"Support for other forums ?", "idk man"}
    ]

    embed =
      Enum.reduce(features, embed, fn {title, text}, embed ->
        Embed.put_field(embed, title, text)
      end)

    Api.create_message!(msg.channel_id, embed: embed)
  end
end
