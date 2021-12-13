defmodule Day11 do
  defmodule Octopus do
    use GenServer

    def new(val) do
      GenServer.start_link(Octopus, {val, [], 0})
    end

    def add_neighbor(pid, neighbor) do
      GenServer.call(pid, {:add_neighbor, neighbor})
    end

    def tick(pid) do
      GenServer.call(pid, :tick)
    end

    def increment(pid) do
      GenServer.call(pid, :increment)
    end

    def flashes(pid) do
      GenServer.call(pid, :flashes)
    end

    @impl true
    def init({val, neighbors, flash_count}) do
      {:ok, {val, neighbors, flash_count}}
    end

    @impl true
    def handle_call(:tick, _from, {val, neighbors, flash_count} = state) do
      cond do
        val > 9 -> handle_increment({0, neighbors, flash_count})
        true -> handle_increment(state)
      end
    end

    @impl true
    def handle_call(:increment, _from, state) do
      handle_increment(state)
    end

    @impl true
    def handle_call({:add_neighbor, new_neighbor}, _from, {val, neighbors, flash_count}) do
      {:reply, nil, {val, [new_neighbor | neighbors], flash_count}}
    end

    @impl true
    def handle_call(:flashes, _from, {val, neighbors, flash_count}) do
      {:reply, flash_count, {val, neighbors, flash_count}}
    end

    def handle_increment({val, neighbors, flash_count}) do
      val = val + 1
      if val == 10 do
        {:reply, neighbors, {val, neighbors, flash_count + 1}}
      else
        {:reply, [], {val, neighbors, flash_count}}
      end
    end
  end

  def add_neighbor(map, point, pid) do
    case map[point] do
      nil -> nil
      neighbor -> Octopus.add_neighbor(neighbor, pid)
    end
  end

  def tick(pids) do
    followups = Enum.reduce(pids, [], fn(pid, acc) -> Enum.concat(acc, Octopus.tick(pid)) end)

    follow_flashes(followups)
  end

  def flash_count(pids) do
    Enum.map(pids, &Octopus.flashes/1) |> Enum.sum
  end

  def ticks_until_sync(pids, tick_count \\ 0) do
    prior_flashes = flash_count(pids)

    tick(pids)

    current_flashes = flash_count(pids)

    if (current_flashes - prior_flashes) == Enum.count(pids) do
      tick_count + 1
    else
      ticks_until_sync(pids, tick_count + 1)
    end
  end

  def run_ticks(pids, 0) do
    flash_count(pids)
  end

  def run_ticks(pids, tick_count) do
    tick(pids)
    run_ticks(pids, tick_count - 1)
  end

  def follow_flashes([]) do
    nil
  end

  def follow_flashes([pid | rest]) do
    followups = Octopus.increment(pid)

    follow_flashes(Enum.concat(rest, followups))
  end

  def parse(input) do
    octopi = for {line, row} <- Enum.with_index(String.split(input)),
      {val, col} <- Enum.with_index(String.graphemes(line)),
      into: %{} do
        {:ok, pid} = Octopus.new(String.to_integer(val))
        {{row, col}, pid}
    end

    Enum.each(octopi, fn ({{x, y} = point, pid}) ->
      add_neighbor(octopi, {x - 1, y - 1}, pid)
      add_neighbor(octopi, {x, y - 1}, pid)
      add_neighbor(octopi, {x + 1, y - 1}, pid)
      add_neighbor(octopi, {x - 1, y}, pid)

      add_neighbor(octopi, {x + 1, y}, pid)
      add_neighbor(octopi, {x - 1, y + 1}, pid)
      add_neighbor(octopi, {x, y + 1}, pid)
      add_neighbor(octopi, {x + 1, y + 1}, pid)
    end)

    octopi
  end
end
