defmodule Unixbot.Application do
  @moduledoc """
  Unixbot supervisor.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Unixbot.Repo, []},
      Unixbot.Consumer,
      Unixbot.Scheduler,
      Reddit.TokenServer
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
