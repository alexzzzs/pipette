defmodule Pipette.Path do
  @moduledoc "Path representation and sigil."

  @type segment :: atom() | integer() | :* | {:filter, (any() -> as_boolean(term()))}
  @type t :: [segment]

  @doc """
  ~p sigil parses a slash path:

      ~p"/users/*/email"  #=> [:users, :*, :email]
      ~p"/items/0/id"     #=> [:items, 0, :id]
  """
  defmacro sigil_p({:<<>>, _, [string]}, _mods) do
    Macro.escape(parse(string))
  end

  @doc """
  Parses a slash path string into a list of segments.

      Pipette.Path.parse("/users/*/email")  #=> [:users, :*, :email]
      Pipette.Path.parse("/items/0/id")     #=> [:items, 0, :id]
  """
  @spec parse(String.t()) :: t()
  def parse(path_string) do
    path_string
    |> String.trim()
    |> String.trim_leading("/")
    |> String.split("/", trim: true)
    |> Enum.map(fn
      "*" -> :*
      part ->
        case Integer.parse(part) do
          {i, ""} -> i
          _ -> String.to_atom(part)
        end
    end)
  end
end
