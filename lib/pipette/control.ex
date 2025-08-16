defmodule PipetteElixir.Control do
  @moduledoc "Pipe control combinators."

  @doc "Run `fun.(value)` without changing the value."
  @spec do_tap(any(), (any() -> any())) :: any()
  def do_tap(value, fun) when is_function(fun, 1) do
    _ = fun.(value)
    value
  end

  @doc "If cond truthy, apply fun; else pass through."
  @spec pipe_when(any(), any(), (any() -> any())) :: any()
  def pipe_when(value, cond, fun) when is_function(fun, 1) do
    if cond, do: fun.(value), else: value
  end

  @doc "Inverse of pipe_when."
  @spec pipe_unless(any(), any(), (any() -> any())) :: any()
  def pipe_unless(value, cond, fun), do: pipe_when(value, !cond, fun)

  @doc """
  Pattern-match inside a pipeline while keeping it flowing.

      user
      |> pipe_case do
           %{email: e} -> String.downcase(e)
           _           -> nil
         end
  """
  defmacro pipe_case(value, do: block) do
    quote do
      case unquote(value) do
        unquote(block)
      end
    end
  end

  @doc """
  Pipe-friendly dbg/1 wrapper controlled by a predicate.

      value |> dbg_when(Mix.env() == :dev)
  """
  @spec dbg_when(any(), boolean()) :: any()
  def dbg_when(value, cond) do
    if cond do
      require Kernel
      Kernel.dbg(value)
    end
    value
  end
end