defmodule Day5 do
  def record(board, location) do
    Map.update(board, location, 1, fn existing -> existing + 1 end)
  end

  def add_line(segment, board) do
    for point <- points_along(segment),
      reduce: board do
        acc -> record(acc, point)
    end
  end

  def points_along({ {x1, y1}, {x2, y2} }) do
    cond do
      x1 == x2 -> for y <- y1..y2, do: {x1, y}
      y1 == y2 -> for x <- x1..x2, do: {x, y1}
      true -> Enum.zip(x1..x2, y1..y2)
    end
  end

  def straight?({{x1, y1}, {x2, y2}}) do
    x1 == x2 || y1 == y2
  end

  def parse(line) do
    [p1, p2] = String.split(line, " -> ")

    [x1, y1] = String.split(p1, ",") |> Enum.map(&String.to_integer/1)
    [x2, y2] = String.split(p2, ",") |> Enum.map(&String.to_integer/1)

    { {x1, y1}, {x2, y2} }
  end

  def line_segments(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&Day5.parse/1)
  end

  def number_of_overlaps(input) do
    straight_segments = Day5.line_segments(input) |> Stream.filter(&Day5.straight?/1)

    board = Enum.reduce(straight_segments, %{}, &Day5.add_line/2)

    Map.values(board) |> Enum.count(&(&1 > 1))
  end

  def all_overlaps(input) do
    Day5.line_segments(input)
    |> Enum.reduce(%{}, &Day5.add_line/2)
    |> Map.values
    |> Enum.count(&(&1 > 1))
  end
end
