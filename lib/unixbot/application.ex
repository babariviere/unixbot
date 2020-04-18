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
      {Unixbot.ChannelCache, %{}},
      {Unixbot.Scheduler, %{}},
      Reddit.TokenServer
    ]

    opts = [strategy: :one_for_one]
    res = Supervisor.start_link(children, opts)

    # Reschedule all subscriptions
    Unixbot.Repo.all(Unixbot.Subscription)
    |> Enum.each(&Unixbot.Subscription.schedule/1)

    res
  end
end
