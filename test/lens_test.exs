
defmodule Pipette.LensTest do
  use ExUnit.Case, async: true
  import Pipette.Lens

  test "key lens views a map value" do
    data = %{a: 1, b: 2}
    lens = key(:a)
    assert view(lens, data) == 1
  end

  test "key lens sets a map value" do
    data = %{a: 1, b: 2}
    lens = key(:a)
    assert set(lens, 10, data) == %{a: 10, b: 2}
  end

  test "key lens applies a function over a map value" do
    data = %{a: 1, b: 2}
    lens = key(:a)
    assert over(lens, &(&1 + 1), data) == %{a: 2, b: 2}
  end

  test "index lens views a list value" do
    data = [1, 2, 3]
    lens = index(1)
    assert view(lens, data) == 2
  end

  test "index lens sets a list value" do
    data = [1, 2, 3]
    lens = index(1)
    assert set(lens, 20, data) == [1, 20, 3]
  end

  test "index lens applies a function over a list value" do
    data = [1, 2, 3]
    lens = index(1)
    assert over(lens, &(&1 * 2), data) == [1, 4, 3]
  end

  test "compose lenses for nested map" do
    data = %{user: %{name: "Alice", age: 30}}
    user_name_lens = compose(key(:user), key(:name))
    assert view(user_name_lens, data) == "Alice"
    assert set(user_name_lens, "Bob", data) == %{user: %{name: "Bob", age: 30}}
    assert over(user_name_lens, &String.upcase/1, data) == %{user: %{name: "ALICE", age: 30}}
  end

  test "compose lenses for map in list" do
    data = [%{id: 1, value: "a"}, %{id: 2, value: "b"}]
    second_item_value_lens = compose(index(1), key(:value))
    assert view(second_item_value_lens, data) == "b"
    assert set(second_item_value_lens, "B", data) == [%{id: 1, value: "a"}, %{id: 2, value: "B"}]
    assert over(second_item_value_lens, &String.upcase/1, data) == [%{id: 1, value: "a"}, %{id: 2, value: "B"}]
  end

  test "pipeline-friendly lens functions" do
    data = %{user: %{name: "Alice", age: 30}}
    user_name_lens = compose(key(:user), key(:name))

    # Test pipeline-friendly versions
    assert data |> view_at(user_name_lens) == "Alice"
    assert data |> set_at(user_name_lens, "Bob") == %{user: %{name: "Bob", age: 30}}
    assert data |> over_at(user_name_lens, &String.upcase/1) == %{user: %{name: "ALICE", age: 30}}
  end
end
