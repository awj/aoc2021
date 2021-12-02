defmodule Day2 do
  defmodule Location do
    defstruct position: 0, depth: 0, aim: 0

    def forward(location, val) do
      # Depth changes by `aim` once for each unit we move forward. (So moving
      # forward 3 with an aim of 5 would result in depth + 15)
      new_depth = location.depth + location.aim * val
      %{location | position: location.position + val, depth: new_depth}
    end

    def down(location, val) do
      %{location | aim: location.aim + val}
    end

    def up(location, val) do
      %{location | aim: location.aim - val}
    end

    # Deep structural matching keeps the code short / easy to read, but *really*
    # ties us to the format of the input text.
    def apply(location, ["forward", val]) do
      Location.forward(location, String.to_integer(val))
    end

    def apply(location, ["down", val]) do
      Location.down(location, String.to_integer(val))
    end

    def apply(location, ["up", val]) do
      Location.up(location, String.to_integer(val))
    end

    def coordinate(location) do
      location.position * location.depth
    end

    def process(input) do
      String.split(String.trim(input), "\n")
      |> Stream.map(&(String.split(&1, " ")))
      |> Enum.reduce(%Location{}, &Location.apply/2)
    end
  end
end
