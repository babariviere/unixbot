defmodule Unixbot do
  @moduledoc """
  Unixbot Supervisor.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Unixbot.Consumer,
      Reddit.TokenServer
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
