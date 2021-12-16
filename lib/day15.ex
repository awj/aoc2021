defmodule Day15 do
  # Build a shitty priority queue by wrapping a map of cost -> data in accessors
  # that track the cheapest costs and maintain a stack of items per cost.
  defmodule ScoredResults do
    @default_cost 1_000_000_000_000
    defstruct results: %{}, cheapest: @default_cost

    def add(sr, cost, val) do
      %ScoredResults{
        results: Map.update(sr.results, cost, [val], fn existing -> [val | existing] end),
        cheapest: min(cost, sr.cheapest)
      }
    end

    def remove(sr) do
      {outcome, results} = Map.get_and_update(sr.results, sr.cheapest, fn val ->
        cond do
          length(val) == 1 -> :pop
          true -> {[hd(val)], tl(val)}
        end
      end)

      new_sr = %ScoredResults{
        results: results,
        cheapest: Enum.min(Map.keys(results))
      }

      {hd(outcome), new_sr}
    end
  end

  defmodule History do
    def cheaper?(history, new_cost, location) do
      if history[location] == nil do
        true
      else
        new_cost < history[location]
      end
    end

    def record(history, cost, location) do
      if history[location] == nil || cost < history[location] do
        Map.put(history, location, cost)
      else
        history
      end
    end
  end

  defmodule Trail do
    defstruct location: {0,0}, seen: MapSet.new, cost: 0

    def options(trail, map, history) do
      {x, y} = trail.location

      for dx <- (x-1)..(x+1),
          dy <- (y-1)..(y+1),
        !(dx == x && dy == y),
        dx == x || dy == y,
        !({dx, dy} in trail.seen),
        map[{dx, dy}] != nil,
        History.cheaper?(history, trail.cost + map[{dx, dy}], {dx, dy}) do
          dest = {dx, dy}
          %Trail{
            location: dest,
            seen: MapSet.put(trail.seen, dest),
            cost: trail.cost + map[dest]
          }
      end
    end

    def expected_cost(trail, destination) do
      {x, y} = trail.location
      {xp, yp} = destination

      h = abs(xp - x) + abs(yp - y)

      trail.cost + h
    end

    def at_destination?(trail, destination) do
      trail.location == destination
    end
  end

  def parse(input) do
    map = for {line, row} <- String.split(input) |> Enum.with_index,
              {val, col} <- String.split(line, "", trim: true) |> Enum.with_index,
      into: %{} do
         {{row, col}, String.to_integer(val)}
    end

    map
  end

  def expand(map, n) do
    {size, _} = Enum.max(Map.keys(map))

    size = size + 1

    for {{x, y}, val} <- map,
      dx <- 0..(n-1),
      dy <- 0..(n-1),
      into: %{} do
        point = {x + (size * dx), y + (size * dy)}
        nval = val + dx + dy
        cond do
          nval > 9 -> {point, nval - 9}
          true -> {point, nval}
        end
    end
  end

  def target(map) do
    map
    |> Map.keys
    |> Enum.max
  end

  def navigate(map) do
    starter_trail = %Trail {
      location: {0, 0},
      seen: MapSet.new([{0,0}]),
      cost: 0
    }

    history = %{}

    options = Trail.options(starter_trail, map, history)

    destination = target(map)

    scores_and_history = mark_options(options, %ScoredResults{}, history, destination)

    find_cheapest_route(map, scores_and_history, destination)
  end

  def mark_options(options, scored, history, destination) do
    {
      Enum.reduce(options, scored, fn (trail, scores) -> ScoredResults.add(scores, Trail.expected_cost(trail, destination), trail) end),
      Enum.reduce(options, history, fn (trail, history) -> History.record(history, trail.cost, trail.location) end)
    }
  end

  def find_cheapest_route(map, {scored, history}, destination) do
    {candidate, scored} = ScoredResults.remove(scored)

    options = Trail.options(candidate, map, history)

    case Enum.find(options, fn option -> Trail.at_destination?(option, destination) end) do
      nil ->
        find_cheapest_route(
          map,
          mark_options(options, scored, history, destination),
          destination
        )
      trail -> trail

    end
  end
end
