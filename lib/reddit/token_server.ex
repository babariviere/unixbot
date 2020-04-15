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

  defmodule State do
    @moduledoc """
    State used for reddit token server.
    """

    defstruct [:credentials, :token]

    @typedoc "State of Reddit.TokenServer"
    @type t() :: %__MODULE__{
            credentials: map(),
            token: String.t() | nil
          }

    def set_token(state, token) do
      %{state | token: token}
    end
  end

  # Server

  @impl true
  def init(_) do
    state = %State{
      credentials: Map.new(Application.get_env(:unixbot, :reddit))
    }

    token = generate_token(state.credentials)
    {:ok, State.set_token(state, token)}
  end

  @impl true
  def handle_call(:get, _from, %State{token: token} = state) do
    {:reply, token, state}
  end

  @impl true
  def handle_info(:refresh, state) do
    # generate token in parallel to avoid blocking when getting old one.
    spawn(fn ->
      token = generate_token(state.credentials)
      send(@server, {:update, token})
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info({:update, token}, state) do
    {:noreply, State.set_token(state, token)}
  end

  @spec generate_token(map()) :: String.t() | nil
  defp generate_token(%{
         username: username,
         password: password,
         client_id: client_id,
         client_secret: client_secret
       }) do
    params = [
      grant_type: "password",
      username: username,
      password: password
    ]

    basic = Base.encode64("#{client_id}:#{client_secret}")

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
        schedule_refresh_token(json["expires_in"] * 999)
        json["access_token"]

      _ ->
        # retry 10 seconds later
        schedule_refresh_token(10 * 1000)
        nil
    end
  end

  @type milliseconds :: non_neg_integer()

  @spec schedule_refresh_token(milliseconds()) :: reference()
  defp schedule_refresh_token(time) do
    Process.send_after(@server, :refresh, time)
  end
end
