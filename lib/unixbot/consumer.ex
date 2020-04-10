defmodule Unixbot.Consumer do
  @moduledoc """
  Consumer of all Discord events.

  Handle all messages and try to give a decent response everytime.
  """

  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  require Logger

  @prefix Application.get_env(:unixbot, :prefix, "!")

  @spec start_link :: no_return
  def start_link do
    Consumer.start_link(__MODULE__)
  end

  defp features do
    msg =
      %Embed{}
      |> Embed.put_title("Features")
      |> Embed.put_description("List of all features that are implemented / planned")

    features = [
      {"Daily top posts", "doing"},
      {"Vote system", "next"},
      {"Classement", "todo"},
      {"Extract configuration from comments", "todo"},
      {"Support for other forums ?", "idk man"}
    ]

    Enum.reduce(features, msg, fn {title, text}, embed -> Embed.put_field(embed, title, text) end)
  end

  @impl true
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Logger.info("new message: #{msg.content}")

    case msg.content do
      @prefix <> "ping" -> Api.create_message(msg.channel_id, "pong")
      @prefix <> "features" -> Api.create_message(msg.channel_id, embed: features())
      _ -> :ok
    end
  end

  @impl true
  def handle_event(_event) do
    :ok
  end
end