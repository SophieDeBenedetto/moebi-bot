defmodule MoebiTest do
  use ExUnit.Case
  doctest Moebi

  test "greets the world" do
    assert Moebi.hello() == :world
  end
end
