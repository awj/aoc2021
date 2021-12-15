defmodule Day14 do
  # Compute the final result of n rounds of production for the provided pair:
  # * if a shortcut exists for {pair, n}, use it instead of computing
  # * if no shortcut exists, compute the frequencies and update shortcuts to
  #   include the newly computed frequencies for {pair, n}
  # * if we get all the way to 0 productions, return the frequencies *just* the
  #   right side of the pair. There either is a corresponding *previous* pair
  #   that contains the left side, or we're looking at the very first pair and
  #   something else will need to add 1 to the left side's value
  #
  # @return [{frequencies, shortcuts}] computed frequencies for {pair, n}, and
  # shortcuts updated to avoid ever again computing {pair, n}
  def compute(pair, map, shortcuts, n)

  def compute({x, y} = pair, _map, shortcuts, 0) do
    freq = %{ y => 1 }

    {freq, Map.put(shortcuts, {pair, 0}, freq)}
  end

  def compute(pair, map, shortcuts, n) do
    case shortcuts[{pair, n}] do
      nil -> # no shortcut, have to do the work
        case expand(pair, map) do
          [left, right] ->
            # Get the left side frequency and (updated) shortcuts at n - 1
            {lfreq, lshortcuts} = compute(left, map, shortcuts, n - 1)
            # Get the right side frequency and (updated) shortcuts at n - 1.
            # Note how we're reusing work from the left side
            {rfreq, rshortcuts} = compute(right, map, lshortcuts, n - 1)

            merged_frequencies = merge_frequencies(lfreq, rfreq)

            # Include {pair, n} in our shortcuts for later
            updated_shortcuts = Map.put(rshortcuts, {pair, n}, merged_frequencies)
            {merged_frequencies, updated_shortcuts}
          [{x, y}] ->
            frequencies = Enum.frequencies([x, y])
            {frequencies, Map.put(shortcuts, {pair, n}, frequencies)}
        end
      x ->
        {x, shortcuts}
    end
  end

  def fast_checksum(frequencies) do
    vals = Map.values(frequencies)

    Enum.max(vals) - Enum.min(vals)
  end

  # Handle the "right side bias" in fast round computation by merging the result
  # with a frequency map of the very leftmost value mapping to 1
  def generate_fast_rounds([{leftest, _} | _tail] = pairs, map, n) do
    merge_frequencies(
      %{ leftest => 1 },
      fast_rounds(pairs, map, n)
    )
  end

  # Walk the list of polymer pairs. Generate frequencies and *update* shortcuts
  # for each pair. Merge the frequencies with whatever we generate for the next
  # pair in line, reusing the shortcuts we just computed along the way.
  def fast_rounds(pairs, map, n, shortcuts \\ %{})

  def fast_rounds([pair | pairs], map, n, shortcuts) do
    {freq, shortcuts} = compute(pair, map, shortcuts, n)

    merge_frequencies(
      freq,
      fast_rounds(pairs, map, n, shortcuts)
    )
  end

  def fast_rounds([], _map, _n, _shortcuts) do
    %{}
  end

  def merge_frequencies(f1, f2) do
    Map.merge(f1, f2, fn _k, v1, v2 -> v1 + v2 end)
  end

  # Given a pairing and the production map, return either a single-element list
  # (because there's no new production), or a two-element list of the new pairs.
  def expand({x, y} = pair, map) do
    case map[pair] do
      nil -> [pair]
      z -> [{x, z}, {z, y}]
    end
  end

  def rounds(pairs, _map, 0) do
    pairs
  end

  def rounds(pairs, map, n) do
    rounds(round(pairs, map), map, n - 1)
  end

  def round(pairs, map) do
    Stream.flat_map(pairs, &(expand(&1, map)))
  end

  def parse(input) do
    lines = input |> String.trim |> String.split("\n", trim: false)

    seed = Enum.at(lines, 0)

    productions = Enum.drop(lines, 2)

    {
      parse_pairs(seed),
      parse_mappings(productions)
    }
  end

  def checksum(polymer) do
    frequencies = polymer |> Enum.frequencies |> Map.values

    Enum.max(frequencies) - Enum.min(frequencies)
  end

  def polymer([head | pairs]) do
    rest = pairs
    |> Stream.map(&(elem(&1, 1)))

    Enum.concat(Tuple.to_list(head), rest)
  end

  def parse_pairs(input) do
    input
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&List.to_tuple/1)
  end

  def parse_mappings(input) do
    for line <- input,
      into: Map.new do
        [start, produces] = String.split(line, " -> ")
        origin = String.graphemes(start) |> List.to_tuple
        {origin, produces}
    end
  end
end
