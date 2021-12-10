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
