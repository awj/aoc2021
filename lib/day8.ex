defmodule Day8 do

  def known_number(signal) do
    case String.length(signal) do
      2 -> 1
      4 -> 4
      3 -> 7
      7 -> 8
      _ -> nil
    end
  end

  # Rules here are structured as:
  # {char_count, %{known_number => intersection_size}, inferred_number}
  #
  # For example 6 is defined by:
  # * contains six characters
  # * intersecting it with 1 gives you 1 element
  # * AND intersecting it with 4 gives you 3 elements
  #
  # For the *other* six-character numbers (0 and 9):
  # * intersecting 0 and 1 gives you two elements
  # * intersecting 6 and 4 gives you four elements
  @rules [
    {6, %{1 => 2, 4 => 3}, 0},
    # 1 is a known number
    {5, %{4 => 2}, 2},
    {5, %{1 => 2}, 3},
    # 4 is a known number
    {5, %{4 => 3}, 5},
    {6, %{1 => 1, 4 => 3}, 6},
    # 7 is a known number
    # 8 is a known number
    {6, %{4 => 4}, 9}
  ]

  def check({size, constraints, _val}, to_check, known) do
    if MapSet.size(to_check) == size do
      Enum.all?(constraints, fn ({known_val, intersection_size}) ->
        MapSet.size(
          MapSet.intersection(known[known_val], to_check)
        ) == intersection_size
      end)
    else
      false
    end
  end

  def identify(signal, known) do
    easy = known_number(signal)

    if easy != nil do
      easy
    else
      exploded = explode(signal)

      {_, _, num} = Enum.find(@rules, fn (rule) -> check(rule, exploded, known) end)

      num
    end
  end

  def explode(signal) do
    MapSet.new(String.graphemes(signal))
  end

  def translate({_signals, outputs}, known) do
    Enum.map(outputs, &(identify(&1, known)))
    |> Integer.undigits(10)
  end

  def known_numbers({signals, outputs}) do
    Enum.concat(signals, outputs)
    |> Enum.reduce(%{}, fn  (signal, acc) ->
      number = known_number(signal)
      if number do
        Map.put(acc, number, explode(signal))
      else
        acc
      end
    end)
  end

  def output_sum(lines) do
    results = Enum.map(lines, fn (line) ->
      known = known_numbers(line)
      Day8.translate(line, known)
    end)

    Enum.sum(results)
  end

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&Day8.parse_line/1)
  end

  def parse_line(line) do
    [signal_text, output_text] = String.split(line, " | ")

    {
      String.split(signal_text),
      String.split(output_text)
    }
  end

  def count_uniques(output) do
    IO.inspect(output, label: "count arg")
    Enum.count(output, fn (item) ->
      length = String.length(item)

      Enum.member?([
        2, # 1 digit
        4, # 4 digit
        3, # 7 digit
        7, # 8 digit
      ],
        length
      )
    end)
  end

  def unique_outputs(content) do
    Enum.reduce(content, 0, fn ({_, outputs}, acc) ->
      acc + Day8.count_uniques(outputs)
    end)
  end
end
