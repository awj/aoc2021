defmodule Day2 do
  defmodule Location do
    defstruct position: 0, depth: 0

    def forward(location, val) do
      %{location | position: location.position + val}
    end

    def down(location, val) do
      %{location | depth: location.depth + val}
    end

    def up(location, val) do
      %{location | depth: location.depth - val}
    end

    def apply(location, "forward", val) do
      Location.forward(location, String.to_integer(val))
    end

    def apply(location, "down", val) do
      Location.down(location, String.to_integer(val))
    end

    def apply(location, "up", val) do
      Location.up(location, String.to_integer(val))
    end

    def coordinate(location) do
      location.position * location.depth
    end

    def process(input) do
      String.split(String.trim(input), "\n")
      |> Stream.map(&(String.split(&1, " ")))
      |> Enum.reduce(%Location{}, fn ([dir, val], location) -> Location.apply(location, dir, val) end)
    end
  end
end
