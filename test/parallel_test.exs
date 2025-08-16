defmodule Pipette.ParallelTest do
  use ExUnit.Case, async: true
  alias Pipette.Parallel

  doctest Pipette.Parallel

  test "pmap is equivalent to Enum.map for CPU-bound tasks" do
    assert Enum.sort(Parallel.pmap(1..100, &(&1 * &1), [])) == Enum.map(1..100, &(&1 * &1)) |> Enum.sort()
  end

  test "pfilter is equivalent to Enum.filter" do
    assert Enum.sort(Parallel.pfilter(1..100, &(rem(&1, 2) == 0), [])) == Enum.filter(1..100, &(rem(&1, 2) == 0)) |> Enum.sort()
  end

  test "pmap_reduce is equivalent to Enum.map |> Enum.reduce" do
    assert Parallel.pmap_reduce(1..100, 0, &(&1 * &1), &(&1 + &2), []) == Enum.reduce(Enum.map(1..100, &(&1 * &1)), 0, &(&1 + &2))
  end
end