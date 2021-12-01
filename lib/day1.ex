defmodule Day1 do
  def count_increase(depth, {count, nil}) do
    {count, depth}
  end

  def count_increase(depth, {count, prev}) do
    if prev < depth do
      { count + 1, depth }
    else
      { count, depth }
    end
  end

  # State is passed here as a two element tuple of:
  # * 1 - a "window" tuple of the previous 0-2 elements
  # * 2 - a list of prior window sums
  #
  # When the window tuple reaches two elements, each new depth appends a sum of
  # those elements and the new depth to the list of window sums. Then slides the
  # oldest window element out and uses the new depth for future measurements.
  def collect_depths(depth, {{}, []}) do
    {{depth}, []}
  end

  def collect_depths(depth, {{d1}, []}) do
    {{d1, depth}, []}
  end

  def collect_depths(depth, {{d1,d2}, out}) do
    sum = d1 + d2 + depth
    {{d2, depth}, [sum | out]}
  end

  def window_sums(depths) do
    {_, depth_sums} = Enum.reduce(depths, {{}, []}, &Day1.collect_depths/2)
    Enum.reverse(depth_sums)
  end

  def increases(depths) do
    { count, _ } = Enum.reduce(depths, {0, nil}, &Day1.count_increase/2)
    count
  end
end
