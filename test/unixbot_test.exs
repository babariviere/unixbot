defmodule UnixbotTest do
  use ExUnit.Case
  doctest Unixbot

  test "greets the world" do
    assert Unixbot.hello() == :world
  end
end
