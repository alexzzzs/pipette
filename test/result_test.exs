defmodule Pipette.ResultTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  

  doctest Pipette.Result

  property "sequence collects all oks" do
    check all(xs <- list_of(term())) do
      rs = Enum.map(xs, &{:ok, &1})
      assert Pipette.Result.sequence(rs) == {:ok, xs}
    end
  end

  property "sequence fails on first error" do
    check all(xs <- list_of(term()),
              e <- term(),
              n <- non_negative_integer()) do
      rs = Enum.map(xs, &{:ok, &1})
      rs = List.insert_at(rs, n, {:error, e})
      assert Pipette.Result.sequence(rs) == {:error, e}
    end
  end
end
