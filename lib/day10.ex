defmodule Day10 do
  def score(closing) do
    case closing do
      ")" -> 3
      "]" -> 57
      "}" -> 1197
      ">" -> 25137
    end
  end

  def corruption_score(line) do
    chars = String.graphemes(line)

    case examine(chars, []) do
      {:balanced, _} -> 0
      {:incomplete, _} -> 0
      {:corrupted, _, closing} -> score(closing)
    end
  end

  # Pick the *middle* element (always an odd number) of the sorted list of
  # autocorrection scores.
  def autocorrect_winner(input) do
    lines = String.split(input)

    scores = Enum.map(lines, &autocorrect_score/1) |> Enum.filter(&(&1 != 0)) |> Enum.sort

    size = Enum.count(scores)

    middle = trunc(size / 2)

    Enum.at(scores, middle)
  end

  def autocorrect_score(line) do
    chars = String.graphemes(line)

    case examine(chars, []) do
      {:balanced, _} -> 0
      {:incomplete, rest} -> completion_score(rest)
      {:corrupted, _, _} -> 0
    end
  end

  # Autocorrect completion is handled by passing a total along as we walk the
  # stack of "leftover" symbols from examination. For each symbol, add a number
  # to the score corresponding to the value for a given symbol's closing brace.
  def completion_score(rest, total \\ 0)

  def completion_score([], total), do: total

  def completion_score([head | rest], total) do
    increment = case head do
      "(" -> 1
      "[" -> 2
      "{" -> 3
      "<" -> 4
                end

    completion_score(rest, total * 5 + increment)
  end

  # Evaluated nested expressions using a stack. General algorithm:
  # * Push all opening braces onto the stack
  # * For closing braces, pop the top of the stack
  # * If they match, discard *both* and keep going
  # * If they don't match, we have a corrupted line
  # * If anything is left on the stack at the end, we have an incomplete line
  def examine([], []) do
    {:balanced, nil}
  end

  def examine([], something) do
    {:incomplete, something}
  end

  def examine([opening | rest], seen) when opening in ["(", "[", "{", "<"] do
    examine(rest, [opening | seen])
  end

  def examine([closing | rest], [balance | seen]) do
    case {balance, closing} do
      {"(", ")"} -> examine(rest, seen)
      {"[", "]"} -> examine(rest, seen)
      {"{", "}"} -> examine(rest, seen)
      {"<", ">"} -> examine(rest, seen)
      _ -> {:corrupted, balance, closing }
    end
  end
 end
