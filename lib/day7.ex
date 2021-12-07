defmodule Day7 do
  def position_cost(crabs, position) do
    Stream.map(crabs, fn (crab) -> abs(crab - position) end)
    |> Enum.sum
  end

  def furthest_crab(crabs) do
    Enum.max(crabs)
  end

  def nearest_crab(crabs) do
    Enum.min(crabs)
  end

  def cheapest_position_cost(crabs) do
    {min, max} = {nearest_crab(crabs), furthest_crab(crabs)}

    best_position = Enum.min_by(min..max, fn (pos) -> position_cost(crabs, pos) end)

    {best_position, position_cost(crabs, best_position) }
  end
end
