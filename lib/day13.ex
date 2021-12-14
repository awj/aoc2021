defmodule Day13 do
  def fold_x(paper, val) do
    for {x, y} <- paper,
      into: MapSet.new do
        cond do
          x > val -> {val - (x - val), y}
          true -> {x, y}
        end
    end
  end

  def fold_y(paper, val) do
    for {x, y} <- paper,
      into: MapSet.new do
        cond do
          y > val -> {x, val - (y - val)}
          true -> {x, y}
        end
    end
  end

  # Recurse over the list of instructions, performing each one and passing the
  # result to the next.
  def perform(paper, []) do
    paper
  end

  def perform(paper, [{"x", val} | rest]) do
    paper
    |> fold_x(val)
    |> perform(rest)
  end

  def perform(paper, [{"y", val} | rest]) do
    paper
    |> fold_y(val)
    |> perform(rest)
  end

  def print(paper) do
    sorted = Enum.sort_by(paper, fn({_x, y}) -> y end)

    for line <- Enum.chunk_by(sorted, fn({_x, y}) -> y end) do
      xs = Enum.map(line, fn({x, _y}) -> x end) |> Enum.sort
      pairs = Enum.chunk_every(xs, 2, 1, :discard)
      offsets = Enum.map(pairs, fn([a, b]) -> b - a end)
      offsets
      |> Enum.map(fn (val) -> String.pad_leading("#", val) end)
      |> Enum.join
    end
  end

  def parse(input) do
    # Trim up any final newlines, but keep the empty line between paper
    # coordinates and instructions for later.
    lines = input |> String.trim |> String.split("\n", trim: false)

    {paper, instructions} = Enum.split_while(lines, fn (l) -> l != "" end)

    # Get rid of the empty line
    instructions = Enum.drop(instructions, 1)

    {
      parse_dots(paper),
      parse_instructions(instructions)
    }
  end

  def parse_dots(points) do
    for point <- points,
      into: MapSet.new do
        [x,y] = String.split(point, ",", trim: true) |> Enum.map(&String.to_integer/1)
        {x, y}
    end
  end

  def parse_instructions(instructions) do
    for line <- instructions do
      [_, _, order] = String.split(line)
      [dir, amount] = String.split(order, "=")

      {dir, String.to_integer(amount)}
    end
  end
end
