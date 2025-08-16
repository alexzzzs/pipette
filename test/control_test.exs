defmodule Pipette.ControlTest do
  use ExUnit.Case, async: true
  import Pipette.Control

  doctest Pipette.Control

  test "do_tap/2" do
    _x = 0
    assert 10 == do_tap(10, fn v -> _x = v end)
  end

  test "pipe_when/3" do
    assert 20 == pipe_when(10, true, &(&1 * 2))
    assert 10 == pipe_when(10, false, &(&1 * 2))
  end

  test "pipe_unless/3" do
    assert 10 == pipe_unless(10, true, &(&1 * 2))
    assert 20 == pipe_unless(10, false, &(&1 * 2))
  end

  test "pipe_case/2" do
    result = 10 |> pipe_case do
      10 -> :ok
      _ -> :error
    end
    assert result == :ok
  end

  test "dbg_when/2" do
    assert 10 == dbg_when(10, true)
    assert 10 == dbg_when(10, false)
  end
end