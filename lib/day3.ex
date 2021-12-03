defmodule Day3 do
  def add_bit_counts(string, counts) do
    String.graphemes(string)
    |> Stream.with_index
    |> Enum.reduce(counts, &Day3.increment_counts/2)
  end

  def increment_counts({val, place}, {zeroes, ones}) do
    increment = fn (map, place) -> Map.put(map, place, (map[place] ||0) + 1) end
    case val do
      "0" -> {increment.(zeroes, place), ones}
      "1" -> {zeroes, increment.(ones, place)}
    end
  end

  def bit_usage(input) do
    counts = {%{}, %{}}

    Enum.reduce(input, counts, &Day3.add_bit_counts/2)
  end

  def harvest_values(map) do
    Enum.sort_by(Map.to_list(map), &(elem(&1, 0)))
    |> Enum.map(&(elem(&1, 1)))
  end

  def combine({zero, one}, {zero_digits, one_digits}) do
    if zero > one do
      {zero_digits ++ [1], one_digits ++ [0]}
    else
      {zero_digits ++ [0], one_digits ++ [1]}
    end
  end

  def checksums({zeroes, ones}) do
    zero_values = harvest_values(zeroes)
    one_values = harvest_values(ones)

    {zero_digits, one_digits} = Enum.zip(zero_values, one_values) |> Enum.reduce({[], []}, &Day3.combine/2)

    { Integer.undigits(zero_digits, 2), Integer.undigits(one_digits, 2) }
  end

  def power_consumption(input) do
    {gamma, epsilon} = bit_usage(input)
     |> checksums

    gamma * epsilon
  end
end
