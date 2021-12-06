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

  def build_tree(input, tree \\ %{})

  def build_tree([input], tree) do
    {old_val, final_tree} = append_tree(
      String.graphemes(input) |> Enum.map(&String.to_integer/1),
      input,
      tree
    )

    final_tree
  end

  def build_tree([input | inputs], tree) do
    {old_val, new_tree} = append_tree(
      String.graphemes(input) |> Enum.map(&String.to_integer/1),
      input,
      tree
    )

    build_tree(inputs, new_tree)
  end

  def append_tree([final], input, tree) do
    Map.get_and_update(tree, final, fn current_value ->
      {current_value, [input | (current_value || [])]}
    end)
  end

  def append_tree([val | values], input, tree) do
    Map.get_and_update(tree, val, fn current_value ->
      {current_value, elem(append_tree(values, input, current_value || %{}), 1)}
    end)
  end

  def value_for(val_tree, [final_bit]) do
    Map.get(val_tree, final_bit)
  end

  def value_for(val_tree, [bit | bits]) do
    value_for(Map.get(val_tree, bit), bits)
  end

  def power_consumption(input) do
    {gamma, epsilon} = Day3.bit_usage(input)   |> Day3.checksums

    Integer.undigits(gamma, 2) * Integer.undigits(epsilon, 2)
  end
end
