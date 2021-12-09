defmodule Day9 do
  defmodule HeightMap do
    defstruct points: %{}, x: 0, y: 0

    def new(input) do
      lines = String.split(input)

      points = for {line, row} <- Enum.with_index(lines),
          {val, col} <- Enum.with_index(String.graphemes(line)),
        into: %{}, do: {{row, col}, String.to_integer(val)}

      %HeightMap{
        points: points,
        y: Enum.count(lines),
        x: String.length(hd(lines))
      }
    end

    def lowest_point_values(heightmap) do
      for {point, value} <- heightmap.points,
          lowest?(heightmap, point),
          do: value
    end

    def lowest?(heightmap, point) do
      point_height = heightmap.points[point]
      Enum.all?(values_around(heightmap, point), fn (adjacent_height) ->
        adjacent_height > point_height
      end)
    end

    def values_around(heightmap, {y, x}) do
      for dx <- (x-1)..(x+1),
          dy <- (y-1)..(y+1),
          !(dx == x && dy == y), # exclude the point we're looking at
          dx >= 0 && dy >= 0 && dx < heightmap.x && dy < heightmap.y, # stay on the map
          do: heightmap.points[{dy, dx}]
    end
  end

  def risk_score(heights) do
    Stream.map(heights, &(&1 + 1))
    |> Enum.sum
  end
end
