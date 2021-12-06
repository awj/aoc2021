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
    if zero < one do
      {zero_digits ++ [1], one_digits ++ [0]}
    else
      {zero_digits ++ [0], one_digits ++ [1]}
    end
  end

  def checksums({zeroes, ones}) do
    zero_values = harvest_values(zeroes)
    one_values = harvest_values(ones)

    Enum.zip(zero_values, one_values) |> Enum.reduce({[], []}, &Day3.combine/2)
  end


  def power_consumption(input) do
    {gamma, epsilon} = Day3.bit_usage(input)   |> Day3.checksums

    Integer.undigits(gamma, 2) * Integer.undigits(epsilon, 2)
  end

  # Walk through the indices of string inputs. At each index identify *only* the
  # ones that fit `criteria`, and use only those for the *next* index. If at any
  # point we only have one value remaining, that's our result.
  def ratings(input, criteria, i \\ 0)

  def ratings([input], _, _) do
    input
  end

  def ratings(inputs, criteria, i) do
    counts = Enum.frequencies_by(inputs, &(String.at(&1, i)))

    remaining = Enum.filter(inputs, &(criteria.(&1, counts, i)))

    IO.puts("#{length(remaining)}, #{i}")

    if i > 100 do
      IO.puts("#{inspect(remaining)}")
      remaining
    else
      Day3.ratings(
        remaining,
        criteria,
        i + 1
      )
    end
  end

  # Oxygen ratings are ones where the `i`-th value is:
  # * the most popular value amongst remaining ratings
  # * "1" if the numbers are equal
  # * everything if only one of "0" or "1" is represented at `i`
  def oxygen_criteria(input, counts, i) do
    val = String.at(input, i)

    count = Map.get(counts, val)

    zero_count = Map.get(counts, "0")
    one_count = Map.get(counts, "1")

    cond do
      count == nil -> true
      zero_count == one_count -> val == "1"
      true -> Enum.max(Map.values(counts)) == count
    end
  end

  # CO2 ratings are ones where the `i`-th value is:
  # * the least popular value amongst remaining ratings
  # * "0" if the numbers are equal
  # * everything if only one of "0" or "1" is represented at `i`
  def co2_criteria(input, counts, i) do
    val = String.at(input, i)

    count = Map.get(counts, val)

    zero_count = Map.get(counts, "0")
    one_count = Map.get(counts, "1")

    cond do
      count == nil -> true
      zero_count == one_count -> val == "0"
      true -> Enum.min(Map.values(counts)) == count
    end
  end

  def scrubber_rating(input) do
    oxygen_value = Day3.ratings(input, &Day3.oxygen_criteria/3)
    co2_value = Day3.ratings(input, &Day3.co2_criteria/3)

    oxygen_rating = Integer.undigits(as_digits(oxygen_value), 2)
    co2_rating = Integer.undigits(as_digits(co2_value), 2)

    oxygen_rating * co2_rating
  end

  def as_digits(input_text) do
    String.graphemes(input_text) |> Enum.map(&String.to_integer/1)
  end
end
