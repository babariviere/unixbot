defmodule Unixbot.Consumer do
  @moduledoc """
  Consumer of all Discord events.

  Handle all messages and try to give a decent response everytime.
  """

  use Nostrum.Consumer

  alias Nostrum.Struct.Message

  require Logger
  import Unixbot.Command

  @prefix Application.get_env(:unixbot, :prefix, "!")

  @spec start_link :: no_return
  def start_link do
    Consumer.start_link(__MODULE__)
  end

  @commands %{
    "subscribe" => Unixbot.Command.Subscribe,
    "list" => Unixbot.Command.List,
    "vote" => Unixbot.Command.Vote,
    "help" => Unixbot.Command.Help
  }
  @doc """
  Return list of all registered commands.
  """
  @spec commands :: map()
  def commands, do: @commands

  @impl true
  def handle_event({:MESSAGE_CREATE, %Message{content: @prefix <> content} = msg, _ws_state}) do
    Logger.debug("new command: #{content}")

    {cmd, args} = parse(content)

    with ce when ce != nil <- Map.get(@commands, cmd) do
      ce.execute(args, msg)
    end
  end

  @impl true
  def handle_event(_event) do
    :ok
  end
end
