defmodule Day17 do
  def solutions(xrange, yrange) do
    for x <- 0..xrange.last,
      y <- (yrange.first - 1)..1_000,
      {xstatus, xtick_range} = simulate_x(x, xrange),
      xstatus in [:reaches, :crossthrough],
      # Pass along the maximum x tick value seen so we know to stop calculating
      # if we start to tick past it.
      {ystatus, ytick_range} = simulate_y(y, yrange, xtick_range.last),
      ystatus in [:reaches, :crossthrough],
      !Range.disjoint?(xtick_range, ytick_range)
      do
      {x, y}
    end
  end

  def best_height_reached(solutions) do
    best_y = Enum.map(solutions, &(elem(&1, 1))) |> Enum.max

    series_velocity_distance(best_y)
  end

  def simulate_y(yvel, yrange, max_x_ticks, y \\ 0, ticks \\ 0, crossed_at_tick \\ nil)

  def simulate_y(yvel, yrange, max_x_ticks, y, ticks, nil) do
    cond do
      y in yrange -> simulate_y(yvel - 1, yrange, max_x_ticks, y + yvel, ticks + 1, ticks)
      ticks > max_x_ticks -> {:misses, -1}
      y < yrange.first -> {:misses, -1}
      true -> simulate_y(yvel - 1, yrange, max_x_ticks, y + yvel, ticks + 1)
    end
  end

  def simulate_y(yvel, yrange, max_x_ticks, y, ticks, crossed_at_tick) do
    cond do
      y in yrange -> simulate_y(yvel - 1, yrange, max_x_ticks, y + yvel, ticks + 1, crossed_at_tick)
      ticks > max_x_ticks -> {:crossthrough, crossed_at_tick..(ticks - 1)}
      true -> {:crossthrough, crossed_at_tick..(ticks - 1)}
    end
  end

  def simulate_x(xvel, xrange, x \\ 0, ticks \\ 0, crossed_at_tick \\ nil)

  # If we reach zero velocity without ever crossing into the x range, the
  # initial velocity was just bad.
  def simulate_x(0, _xrange, _x, _ticks, nil) do
    {:misses, -1}
  end

  # If we reach zero velocity while within the x range, we'll stay in range for
  # all future ticks.
  def simulate_x(0, _xrange, _x, _ticks, crossed_at_tick) do
    {:reaches, crossed_at_tick..1_000_000}
  end

  # When we haven't (yet) crossed into the range:
  # * if we cross into it, note this as the starting tick and continue simulating with that knowledge
  # * if we pass the range entirely, we "skipped" it and missed our change
  # * otherwise, continue simulating by deriving the next x position and the next tick
  def simulate_x(xvel, xrange, x, ticks, nil) do
    cond do
      x in xrange -> simulate_x(xvel - 1, xrange, x + xvel, ticks + 1, ticks)
      x > xrange.last -> {:misses, -1}
      true -> simulate_x(xvel - 1, xrange, x + xvel, ticks + 1)
    end
  end

  # When we have crossed into the range:
  # * if we cross out it, return a crossthrough with the range of ticks from when we started and left
  # * otherwise, continue simulating by deriving the next x position and the next tick
  def simulate_x(xvel, xrange, x, ticks, crossed_at_tick) do
    cond do
      x in xrange -> simulate_x(xvel - 1, xrange, x + xvel, ticks + 1, crossed_at_tick)
      true -> {:crossthrough, crossed_at_tick..(ticks - 1)}
    end
  end

  def distinct_velocities(solutions) do
    solutions
    |> Stream.flat_map(&Tuple.to_list/1)
    |> Stream.uniq
    |> Enum.count
  end

  # In either the X direction or vertical Y direction, we end up with a
  # (reversed) arithmetic sequence.
  # For example for vel 6 we have values of: 6, 5, 4, 3, 2, 1
  # or if we worked backwards:               1, 2, 3, 4, 5, 6
  #
  # The *sum* of this sequence at any particular value n is given by:
  # (n * (n + 1)) / 2.
  #
  # So we can use that to directly convert an initial velocity into a distance
  def series_velocity_distance(vel) do
    round( (vel * (vel + 1) ) / 2 )
  end
end
