defmodule PipetteElixir.Result do
  @moduledoc "Result helpers for {:ok, _} / {:error, _} flows."
  @type result(a) :: {:ok, a} | {:error, term()}

  @spec ok(a) :: result(a) when a: var
  def ok(a), do: {:ok, a}

  @spec error(term()) :: result(any())
  def error(e), do: {:error, e}

  @doc "Convert nil/blank to error; pass through non-nil as {:ok, value}."
  @spec presence(any(), term()) :: result(any())
  def presence(nil, err) do
    {:error, err}
  end
  def presence("", err) do
    {:error, err}
  end
  def presence(v, _) do
    {:ok, v}
  end

  @doc "Map ok value; leave error untouched."
  @spec map_ok(result(a), (a -> b)) :: result(b) when a: var, b: var
  def map_ok({:ok, v}, f), do: {:ok, f.(v)}
  def map_ok({:error, e}, _), do: {:error, e}

  @doc "Map error value; leave ok untouched."
  @spec map_error(result(a), (term() -> term())) :: result(a) when a: var
  def map_error({:ok, v}, _), do: {:ok, v}
  def map_error({:error, e}, f), do: {:error, f.(e)}

  @doc "Monadic bind/and_then."
  @spec bind(result(a), (a -> result(b))) :: result(b) when a: var, b: var
  def bind({:ok, v}, f), do: f.(v)
  def bind({:error, e}, _), do: {:error, e}

  @doc "Provide a default when error."
  @spec with_default(result(a), a) :: a when a: var
  def with_default({:ok, v}, _), do: v
  def with_default({:error, _}, default), do: default

  @doc "Sequence a list of results -> result of list."
  @spec sequence([result(a)]) :: result([a]) when a: var
  def sequence(results) do
    Enum.reduce_while(results, {:ok, []}, fn
      {:ok, v}, {:ok, acc} -> {:cont, {:ok, [v | acc]}}
      {:error, e}, _ -> {:halt, {:error, e}}
    end)
    |> case do
      {:ok, acc} -> {:ok, Enum.reverse(acc)}
      err -> err
    end
  end

  @doc "Traverse enum with f returning result."
  @spec traverse(Enum.t(), (any() -> result(b))) :: result([b]) when b: var
  def traverse(enum, f), do: enum |> Enum.map(f) |> sequence()
end