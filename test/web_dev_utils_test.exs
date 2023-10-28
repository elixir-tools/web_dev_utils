defmodule WebDevUtilsTest do
  use ExUnit.Case
  doctest WebDevUtils

  test "greets the world" do
    assert WebDevUtils.hello() == :world
  end
end
