defmodule Day6 do
  defmodule FishPond do
    use GenServer

    @default_age 6
    @default_new_age 8

    @max_fish 100
    @min_fish 10

    def new(fish) do
      GenServer.start_link(FishPond, fish)
    end

    def tick(pid) do
      GenServer.call(pid, :tick)
    end

    def population(pid) do
      GenServer.call(pid, :population)
    end

    @impl true
    def init(fish) do
      {:ok, fish}
    end

    @impl true
    def handle_call(:tick, _from, fish) do
      new_fish = Enum.flat_map(fish, fn (age) ->
        new_age = age - 1

        if new_age < 0 do
          [@default_age, @default_new_age]
        else
          [new_age]
        end
      end)

      count = Enum.count(new_fish)
      if count > @max_fish do
        new_pools = Enum.drop(new_fish, @max_fish) |> Enum.chunk_every(@min_fish) |> Enum.map(fn (pop) ->
          {:ok, pid} = FishPond.new(pop)
          pid
        end)

        {:reply, new_pools, Enum.take(new_fish, @max_fish) }
      else
        {:reply, [], new_fish }
      end
    end

    @impl true
    def handle_call(:population, _from, fish) do
      count = Enum.count(fish)
      {:reply, count, fish }
    end
  end

  def simulate(starting_state, days) do
    ponds  = String.split(starting_state, ",")
    |> Stream.map(&String.to_integer/1)
    |> Enum.chunk_every(10)
    |> Enum.map(fn (init_fish) ->
      {:ok, pid} = Day6.FishPond.new(init_fish)
      pid
    end)

    final_ponds = Enum.reduce(1..days, ponds, fn (day, ponds) ->
      results = Enum.flat_map(ponds, &FishPond.tick/1)
      new_ponds = Enum.concat(results, ponds)
      count = Stream.map(new_ponds, &FishPond.population/1) |> Enum.sum
      IO.puts "#{day}: #{count} (#{Enum.count(ponds)} ponds)"
      new_ponds
    end)

    count = Stream.map(final_ponds, &FishPond.population/1) |> Enum.sum

    Enum.map(final_ponds, &(GenServer.stop(&1)))

    count
  end
end
