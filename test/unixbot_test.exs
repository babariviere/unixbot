defmodule UnixbotTest do
  use ExUnit.Case
  doctest Unixbot.Command

  alias Ecto.Adapters.SQL.Sandbox

  setup tags do
    :ok = Sandbox.checkout(Unixbot.Repo)

    unless tags[:async] do
      Sandbox.mode(Unixbot.Repo, {:shared, self()})
    end

    :ok
  end
end
