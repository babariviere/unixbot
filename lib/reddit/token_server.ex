defmodule Reddit.TokenServer do
  @moduledoc """
  A server to handle token generation from reddit.

  This try to keep the token extra fresh.
  """

  use GenServer

  @server Reddit.TokenServer

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, [], name: @server)
  end

  def get_token() do
    GenServer.call(@server, :get)
  end

  # Server

  @impl true
  def init(_) do
    token = generate_token(self())
    {:ok, token}
  end

  @impl true
  def handle_call(:get, _from, token) do
    {:reply, token, token}
  end

  @impl true
  def handle_info(:refresh, state) do
    ref = self()
    # generate token in parallel to avoid blocking when getting old one.
    spawn(fn ->
      token = generate_token(ref)
      send(ref, {:update, token})
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info({:update, token}, _state) do
    {:noreply, token}
  end

  @credentials Application.get_env(:unixbot, :reddit)

  @spec generate_token(pid()) :: String.t() | nil
  defp generate_token(pid) do
    params = [
      grant_type: "password",
      username: @credentials[:username],
      password: @credentials[:password]
    ]

    basic = Base.encode64("#{@credentials[:client_id]}:#{@credentials[:client_secret]}")

    headers = [
      Authorization: "Basic #{basic}"
    ]

    resp =
      HTTPoison.post(
        "https://www.reddit.com/api/v1/access_token",
        [],
        headers,
        params: params
      )

    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, json} = Poison.decode(body)

        # send_after expires_in - 1 to still get a valid token during refresh
        schedule_refresh_token(pid, json["expires_in"] * 999)
        json["access_token"]

      _ ->
        # retry 10 seconds later
        schedule_refresh_token(pid, 10 * 1000)
        nil
    end
  end

  @type milliseconds :: non_neg_integer()

  @spec schedule_refresh_token(pid(), milliseconds()) :: no_return()
  defp schedule_refresh_token(pid, time) do
    Process.send_after(pid, :refresh, time)
  end
end
