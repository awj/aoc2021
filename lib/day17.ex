defmodule Day17 do
  def solutions(xrange, yrange) do
    pos_yrange = normalize(yrange)

    for x <- 0..xrange.last,
      y <- (yrange.first - 1)..1_000,
      {xstatus, ticks} = simulate_x(x, xrange),
      xstatus in [:reaches, :crossthrough],
      y_reaches_range?(y, yrange, xstatus, ticks) do
      {x, y}
    end
  end

  def best_height_reached(solutions) do
    best_y = Enum.map(solutions, &(elem(&1, 1))) |> Enum.max

    series_velocity_distance(best_y)
  end

  def y_reaches_range?(yvel, yrange, x_handling, x_ticks)

  def y_reaches_range?(yvel, yrange, :reaches, _x_ticks) do
    {result, _ticks} = simulate_y(yvel, yrange, :unlimited)

    result == :reaches
  end

  def y_reaches_range?(yvel, yrange, :crossthrough, x_ticks) do
    {result, _ticks} = simulate_y(yvel, yrange, x_ticks)

    result == :reaches
  end

  def simulate_y(yvel, yrange, tick_limit, y \\ 0, ticks \\ 0)

  def simulate_y(yvel, yrange, :unlimited, y, ticks) do
    cond do
      y + yvel in yrange -> { :reaches, ticks + 1}
      (yrange.last < 0 && y + yvel < yrange.last) -> {:misses, -1}
      true -> simulate_y(yvel - 1, yrange, :unlimited, y + yvel, ticks + 1)
    end
  end

  def simulate_y(yvel, yrange, tick_limit, y, ticks) do
    cond do
      ticks > tick_limit -> {:misses, -1}
      (ticks == tick_limit) && y + yvel in yrange -> {:reaches, ticks + 1}
      (ticks == tick_limit) -> {:misses, -1}
      true -> simulate_y(yvel - 1, yrange, tick_limit, y + yvel, ticks + 1)
    end
  end

  def simulate_x(xvel, xrange, x \\ 0, ticks \\ 0)

  def simulate_x(xvel, xrange, x, ticks) when xvel in [0, 1] do
    if x + xvel in xrange do
      {:reaches, -1}
    else
      {:misses, -1}
    end
  end

  def simulate_x(xvel, xrange, x, ticks) do
    cond do
      x > xrange.last -> {:misses, -1}
      x + xvel > xrange.last && x in xrange -> {:crossthrough, ticks}
      true -> simulate_x(xvel - 1, xrange, x + xvel, ticks + 1)
    end
  end

  def normalize(range) do
    {first, last} = {range.first, range.last}

    if (first < 0 && last > 0) || (first > 0 && last < 0) do
      raise "uh oh, range crosses zero line"
    end

    first = abs(first)
    last = abs(last)

    pymin = min(first, last)
    pymax = max(first, last)
    pymin..pymax
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
