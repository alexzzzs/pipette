defmodule PipetteElixir do
  @moduledoc """
  Pipeline-first utilities: control, result, deep paths, bounded parallelism.
  """

  require PipetteElixir.Control
  require PipetteElixir.Result
  require PipetteElixir.Deep
  require PipetteElixir.Parallel

  defdelegate do_tap(v, f),         to: PipetteElixir.Control, as: :do_tap
  defdelegate pipe_when(v,c,f),  to: PipetteElixir.Control
  defdelegate pipe_unless(v,c,f),to: PipetteElixir.Control
  defdelegate dbg_when(v,c),     to: PipetteElixir.Control
  defmacro pipe_case(v, do: blk), do: quote do: PipetteElixir.Control.pipe_case(unquote(v), do: unquote(blk))

  defdelegate ok(v),             to: PipetteElixir.Result
  defdelegate error(e),          to: PipetteElixir.Result
  defdelegate presence(v, err),       to: PipetteElixir.Result
  defdelegate bind(r,f),         to: PipetteElixir.Result
  defdelegate and_then(r,f),     to: PipetteElixir.Result, as: :bind
  defdelegate map_ok(r,f),       to: PipetteElixir.Result
  defdelegate map_error(r,f),    to: PipetteElixir.Result
  defdelegate with_default(r,d), to: PipetteElixir.Result
  defdelegate sequence(rs),      to: PipetteElixir.Result
  defdelegate traverse(xs,f),    to: PipetteElixir.Result

  defdelegate dig_get(d,p,defv), to: PipetteElixir.Deep
  defdelegate dig_put(d,p,v),           to: PipetteElixir.Deep
  defdelegate dig_update(d,p,f),        to: PipetteElixir.Deep
  defdelegate dig_pop(d,p),             to: PipetteElixir.Deep

  defdelegate pmap(e,f,opts),         to: PipetteElixir.Parallel
  defdelegate pmap_reduce(e,i,m,r,opts), to: PipetteElixir.Parallel
  defdelegate pfilter(e,p,opts),      to: PipetteElixir.Parallel
end