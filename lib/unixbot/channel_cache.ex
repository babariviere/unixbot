defmodule Unixbot.ChannelCache do
  @moduledoc """
  A channel cache to keep informations of all discord channels.
  """

  use GenServer

  alias Unixbot.Post
  import Ecto.Query, only: [from: 2]

  @server __MODULE__

  # Client

  @doc """
  Starts a `GenServer` process.
  """
  @spec start_link(map()) :: GenServer.on_start()
  def start_link(state \\ %{}) do
    GenServer.start_link(@server, state, name: @server)
  end

  @doc """
  Get last post from channel.
  """
  @spec last_post(integer()) :: Post.t() | nil
  def last_post(channel_id) do
    GenServer.call(@server, {:last_post, channel_id})
  end

  @doc """
  Register a new post in a channel.
  """
  @spec new_post(Post.t()) :: :ok
  def new_post(post) do
    GenServer.cast(@server, {:new_post, post})
  end

  # Server

  @impl true
  def init(state \\ %{}) do
    state =
      from(p in Unixbot.Post,
        distinct: [p.channel_id],
        order_by: [desc: p.updated_at]
      )
      |> Unixbot.Repo.all()
      |> Enum.reduce(state, fn post, acc ->
        set_channel_last_post(acc, post)
      end)

    {:ok, state}
  end

  ## Call

  @impl true
  def handle_call({:last_post, channel_id}, _from, state) do
    post =
      case Map.get(state, channel_id) do
        nil -> nil
        channel -> Map.get(channel, :last_post)
      end

    {:reply, post, state}
  end

  ## Cast

  @impl true
  def handle_cast({:new_post, post}, state) do
    if post do
      state = set_channel_last_post(state, post)

      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  defp set_channel_last_post(state, post) do
    Map.update(state, post.channel_id, %{last_post: post}, fn channel ->
      Map.put(channel, :last_post, post)
    end)
  end
end
