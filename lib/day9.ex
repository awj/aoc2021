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

    def discover_basin(heightmap, points, latest) do
      expanded_basin = expand_basin(heightmap, points, latest)

      if length(expanded_basin) == 0 do
        points
      else
        discover_basin(heightmap, Enum.concat(points, expanded_basin), expanded_basin)
      end
    end

    def expand_basin(heightmap, all_points, latest) do
      Stream.flat_map(latest, fn (point) ->
        points_adjacent(heightmap, point)
      end)
      |> Stream.filter(fn(point) -> heightmap.points[point] < 9 end)
      |> Stream.filter(fn(point) -> !(point in all_points) end)
      |> Enum.uniq
    end

    def lowest_points(heightmap) do
      for point <- Map.keys(heightmap.points),
          lowest?(heightmap, point),
          do: point
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

    def points_adjacent(heightmap, {y, x}) do
      for dx <- (x-1)..(x+1),
          dy <- (y-1)..(y+1),
          !(dx == x && dy == y), # exclude the point we're looking at
          dx == x || dy == y, # don't go diagonal
          dx >= 0 && dy >= 0 && dx < heightmap.x && dy < heightmap.y, # stay on the map
          do: {dy, dx}
    end

    def points_around(heightmap, {y, x}) do
      for dx <- (x-1)..(x+1),
          dy <- (y-1)..(y+1),
          !(dx == x && dy == y), # exclude the point we're looking at
          dx >= 0 && dy >= 0 && dx < heightmap.x && dy < heightmap.y, # stay on the map
          do: {dy, dx}
    end

    def values_around(heightmap, central_point) do
      for point <- points_around(heightmap, central_point),
          do: heightmap.points[point]
    end
  end

  def risk_score(heights) do
    Stream.map(heights, &(&1 + 1))
    |> Enum.sum
  end

  def basins(heightmap) do
    HeightMap.lowest_points(heightmap)
    |> Enum.map(fn (low_point) -> HeightMap.discover_basin(heightmap, [low_point], [low_point]) end)
  end

  def largest_basin_sizes(basins) do
    Enum.map(basins, &Enum.count/1)
    |> Enum.sort(&(&1 >= &2)) # sort highest values first
  end
end
