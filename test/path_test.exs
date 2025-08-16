defmodule Pipette.PathTest do
  use ExUnit.Case, async: true
  import Pipette.Path

  doctest Pipette.Path

  test "~p sigil" do
    assert ~p"/users/*/email" == [:users, :*, :email]
    assert ~p"/items/0/id" == [:items, 0, :id]
  end
end
