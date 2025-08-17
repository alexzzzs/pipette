defmodule Pipette.Parallel do
  @moduledoc "Bounded parallelism that feels like Enum."
  @type pmap_opt ::
          {:max_concurrency, pos_integer()}
          | {:timeout, timeout()}
          | {:ordered, boolean()}

  @doc """
  Parallel map with configurable concurrency.

  ## Examples

      iex> Pipette.Parallel.pmap(1..5, &(&1 * 2), max_concurrency: 2)
      [2, 4, 6, 8, 10]

      iex> Pipette.Parallel.pmap(["a", "b", "c"], &String.upcase/1, ordered: false) |> Enum.sort()
      ["A", "B", "C"]
  """
  @spec pmap(Enumerable.t(), (any() -> any()), [pmap_opt]) :: [any()]
  def pmap(enum, fun, opts) do
    max_conc = Keyword.get(opts, :max_concurrency, System.schedulers_online() * 4)
    timeout  = Keyword.get(opts, :timeout, 30_000)
    ordered  = Keyword.get(opts, :ordered, true)

    stream =
      Task.async_stream(enum, fun,
        max_concurrency: max_conc,
        timeout: timeout,
        ordered: ordered
      )

    for {:ok, v} <- stream, do: v
  end

  @doc """
  Parallel reduce. Order-insensitive by default.

  ## Examples

      iex> Pipette.Parallel.pmap_reduce(1..100, 0, &(&1 * &1), &(&1 + &2), max_concurrency: 4)
      338350
  """
  @spec pmap_reduce(Enumerable.t(), acc, (any() -> any()), (acc, any() -> acc), [pmap_opt]) :: acc when acc: var
  def pmap_reduce(enum, init, mapper, reducer, opts) do
    enum
    |> pmap(mapper, opts)
    |> Enum.reduce(init, reducer)
  end

  @doc """
  Parallel filter via mapper that returns boolean.

  ## Examples

      iex> Pipette.Parallel.pfilter(1..10, &(rem(&1, 2) == 0), max_concurrency: 8)
      [2, 4, 6, 8, 10]

      iex> Pipette.Parallel.pfilter(["apple", "banana", "cherry"], &(String.length(&1) > 5), [])
      ["banana", "cherry"]
  """
  @spec pfilter(Enumerable.t(), (any() -> as_boolean(term())), [pmap_opt]) :: [any()]
  def pfilter(enum, pred, opts) do
    enum
    |> pmap(fn x -> {x, pred.(x)} end, opts)
    |> Enum.flat_map(fn
      {x, true} -> [x]
      _ -> []
    end)
  end
end
