defmodule Pipette.Deep do
  @moduledoc "Deep data manipulation with paths and wildcards."
  alias Pipette.Path, as: Path

  @type path :: Path.t()

  @doc """
  Get a value from nested data using a path, with nil as default.

  ## Examples

      iex> data = %{user: %{name: "Alice"}}
      iex> Pipette.Deep.dig_get(data, [:user, :name])
      "Alice"

      iex> data = %{user: %{name: "Alice"}}
      iex> Pipette.Deep.dig_get(data, [:user, :email])
      nil
  """
  @spec dig_get(any(), path) :: any()
  def dig_get(data, path) when is_list(path), do: dig_get(data, path, nil)
  def dig_get(_data, path) do
    raise ArgumentError, "Path must be a list, got: #{inspect(path)}"
  end

  @spec dig_get(any(), path, any()) :: any()
  def dig_get(data, [], _default), do: data
  def dig_get(data, [seg | rest], default) do
    case seg do
      :* ->
        # fan-out over lists/maps
        case data do
          list when is_list(list) ->
            list
            |> Enum.map(&dig_get(&1, rest, default))
          map when is_map(map) ->
            map
            |> Map.values()
            |> Enum.map(&dig_get(&1, rest, default))
          _ -> default
        end

      key when is_atom(key) ->
        dig_get(access(data, key, default), rest, default)

      idx when is_integer(idx) and is_list(data) ->
        dig_get(Enum.at(data, idx, default), rest, default)

      _ ->
        default
    end
  end

  defp access(map, key, default) when is_map(map), do: Map.get(map, key, default)
  defp access(_, _key, default), do: default

  @spec dig_put(any(), path, any()) :: any()
  def dig_put(_data, [], value), do: value
  def dig_put(data, path, value) when is_list(path) do
    dig_put_impl(data, path, value)
  end
  def dig_put(_data, path, _value) do
    raise ArgumentError, "Path must be a list, got: #{inspect(path)}"
  end

  defp dig_put_impl(_data, [], value), do: value
  defp dig_put_impl(data, [seg | rest], value) do
    case {seg, data} do
      {key, map} when is_atom(key) and is_map(map) ->
        Map.update(map, key, dig_put_impl(%{}, rest, value), &dig_put_impl(&1, rest, value))

      {idx, list} when is_integer(idx) and is_list(list) ->
        List.update_at(pad_list(list, idx), idx, &dig_put_impl(&1 || %{}, rest, value))

      _ ->
        # create structure if missing
        case seg do
          key when is_atom(key) -> %{key => dig_put_impl(%{}, rest, value)}
          idx when is_integer(idx) -> List.update_at(pad_list([], idx), idx, fn _ -> dig_put_impl(%{}, rest, value) end)
          :* -> raise ArgumentError, "dig_put does not support wildcard writes"
        end
    end
  end

  defp pad_list(list, idx) when idx < length(list), do: list
  defp pad_list(list, idx), do: list ++ List.duplicate(nil, idx - length(list) + 1)

  @spec dig_update(any(), path, (any() -> any())) :: any()
  def dig_update(data, path, fun) when is_list(path) and is_function(fun, 1) do
    current = dig_get(data, path, nil)
    dig_put(data, path, fun.(current))
  end
  def dig_update(_data, path, _fun) when not is_list(path) do
    raise ArgumentError, "Path must be a list, got: #{inspect(path)}"
  end
  def dig_update(_data, _path, fun) when not is_function(fun, 1) do
    raise ArgumentError, "Function must be arity 1, got: #{inspect(fun)}"
  end

  @spec dig_pop(any(), path) :: {any(), any()}
  def dig_pop(data, path) when is_list(path) do
    val = dig_get(data, path, nil)
    {val, dig_put(data, path, nil)}
  end
  def dig_pop(_data, path) do
    raise ArgumentError, "Path must be a list, got: #{inspect(path)}"
  end
end
