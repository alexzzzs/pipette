
defmodule Pipette.Lens do
  @moduledoc """
  Functional lenses for Elixir data structures.

  Lenses provide a way to focus on a part of a data structure and then
  get, set, or modify that part without mutating the original structure.
  """

  @type lens(s, a) :: %{
          view: (s -> a),
          set: (a, s -> s)
        }

  @doc """
  Creates a lens that focuses on a specific key in a map.
  """
  @spec key(atom()) :: lens(map(), any())
  def key(k) do
    %{ 
      view: fn m -> Map.get(m, k) end,
      set: fn v, m -> Map.put(m, k, v) end
    }
  end

  @doc """
  Creates a lens that focuses on a specific index in a list.
  """
  @spec index(integer()) :: lens(list(), any())
  def index(i) do
    %{ 
      view: fn l -> Enum.at(l, i) end,
      set: fn v, l -> List.replace_at(l, i, v) end
    }
  end

  @doc """
  Composes two lenses.

  The resulting lens focuses on the part of the data structure that the
  second lens focuses on, within the context of what the first lens
  focuses on.
  """
  @spec compose(lens(s, a), lens(a, b)) :: lens(s, b) when s: var, a: var, b: var
  def compose(lens1, lens2) do
    %{
      view: fn s ->
        s |> lens1.view.() |> lens2.view.()
      end,
      set: fn b, s ->
        intermediate_s = lens1.view.(s)
        new_intermediate_s = lens2.set.(b, intermediate_s)
        lens1.set.(new_intermediate_s, s)
      end
    }
  end

  @doc """
  Views the value at the focus of the lens.
  """
  @spec view(lens(s, a), s) :: a when s: var, a: var
  def view(lens, data), do: lens.view.(data)

  @doc """
  Sets the value at the focus of the lens.
  """
  @spec set(lens(s, a), a, s) :: s when s: var, a: var
  def set(lens, value, data), do: lens.set.(value, data)

  @doc """
  Applies a function to the value at the focus of the lens.
  """
  @spec over(lens(s, a), (a -> a), s) :: s when s: var, a: var
  def over(lens, fun, data) do
    value = view(lens, data)
    new_value = fun.(value)
    set(lens, new_value, data)
  end
end
