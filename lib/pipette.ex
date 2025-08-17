defmodule Pipette do
  @moduledoc """
  Pipeline-first utilities: control, result, deep paths, bounded parallelism.
  """

  require Pipette.Control
  require Pipette.Result
  require Pipette.Deep
  require Pipette.Parallel

  defdelegate do_tap(v, f),         to: Pipette.Control, as: :do_tap
  defdelegate pipe_when(v,c,f),  to: Pipette.Control
  defdelegate pipe_unless(v,c,f),to: Pipette.Control
  defdelegate dbg_when(v,c),     to: Pipette.Control
  defmacro pipe_case(v, do: blk), do: quote do: Pipette.Control.pipe_case(unquote(v), do: unquote(blk))

  defdelegate ok(v),             to: Pipette.Result
  defdelegate error(e),          to: Pipette.Result
  defdelegate presence(v, err),       to: Pipette.Result
  defdelegate bind(r,f),         to: Pipette.Result
  defdelegate and_then(r,f),     to: Pipette.Result, as: :bind
  defdelegate map_ok(r,f),       to: Pipette.Result
  defdelegate map_error(r,f),    to: Pipette.Result
  defdelegate with_default(r,d), to: Pipette.Result
  defdelegate sequence(rs),      to: Pipette.Result
  defdelegate traverse(xs,f),    to: Pipette.Result

  defdelegate dig_get(d,p), to: Pipette.Deep
  defdelegate dig_get(d,p,defv), to: Pipette.Deep
  defdelegate dig_put(d,p,v),           to: Pipette.Deep
  defdelegate dig_update(d,p,f),        to: Pipette.Deep
  defdelegate dig_pop(d,p),             to: Pipette.Deep

  defdelegate pmap(e,f,opts),         to: Pipette.Parallel
  defdelegate pmap_reduce(e,i,m,r,opts), to: Pipette.Parallel
  defdelegate pfilter(e,p,opts),      to: Pipette.Parallel
end
