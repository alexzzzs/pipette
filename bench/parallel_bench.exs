Benchee.run(
  %{
    "Enum.map" => fn -> Enum.map(1..1000, fn i -> :timer.sleep(1); i * i end) end,
    "Pipette.Parallel.pmap (ordered)" => fn -> Pipette.Parallel.pmap(1..1000, fn i -> :timer.sleep(1); i * i end, ordered: true) end,
    "Pipette.Parallel.pmap (unordered)" => fn -> Pipette.Parallel.pmap(1..1000, fn i -> :timer.sleep(1); i * i end, ordered: false) end
  },
  time: 10,
  memory_time: 2
)
