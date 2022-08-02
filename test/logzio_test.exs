defmodule LogzioTest do
  use ExUnit.Case
  doctest Logzio

  test "greets the world" do
    assert Logzio.hello() == :world
  end
end
