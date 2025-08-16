defmodule Pipette.DeepTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import Pipette.Deep
  

  doctest Pipette.Deep

  property "dig_put then dig_get is identity" do
    check all(data <- term(),
              path_str <- string([?a..?z, ?0..?9], min_length: 1),
              value <- term()) do
      path = Pipette.Path.parse(path_str)
      
      # Now, I will check if the path is valid
      # A valid path does not contain :*
      unless Enum.member?(path, :*) do
        assert dig_get(dig_put(data, path, value), path, nil) == value
      end
    end
  end
end