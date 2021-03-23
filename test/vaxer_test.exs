defmodule VaxerTest do
  use ExUnit.Case
  doctest Vaxer

  test "greets the world" do
    assert Vaxer.hello() == :world
  end
end
