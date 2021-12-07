defmodule Day7 do
  def position_cost(crabs, position) do
    Stream.map(crabs, fn (crab) -> abs(crab - position) end)
    |> Enum.sum
  end

  def exponential_movement_cost(crab, position) do
    diff = abs(crab - position)
    case diff do
      0 -> 0
      _ -> Enum.sum(1..diff)
    end
  end

  def exponential_position_cost(crabs, position) do
    Stream.map(crabs, fn (crab) ->
      exponential_movement_cost(crab, position)
    end)
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

  # "exponential" is kind of poor naming here. It's really "linear", but that
  # feels weird too.
  def cheapest_exponential_position_cost(crabs) do
    {min, max} = {nearest_crab(crabs), furthest_crab(crabs)}

    best_position = Enum.min_by(min..max, fn (pos) -> exponential_position_cost(crabs, pos) end)

    {best_position, exponential_position_cost(crabs, best_position) }
  end
end
