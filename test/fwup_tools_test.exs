defmodule FwupToolsTest do
  use ExUnit.Case
  doctest FwupTools

  test "greets the world" do
    assert FwupTools.hello() == :world
  end
end
