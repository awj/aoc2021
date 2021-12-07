defmodule Day6 do
  defmodule Lanternfish do
    use GenServer

    @default_age 6
    @default_new_age 8

    def spawn_fish(age \\ @default_new_age) do
      GenServer.start_link(Lanternfish, age)
    end

    def tick(pid) do
      GenServer.call(pid, :tick)
    end

    def population(pid) do
      GenServer.call(pid, :population)
    end

    @impl true
    def init(age) do
      {:ok, {age, []}}
    end

    @impl true
    def handle_call(:tick, _from, { age, children }) do
      Enum.map(children, &(Lanternfish.tick(&1)))

      age = age - 1

      if age == -1 do
        age = @default_age
        new_children = [new_fish | children]
        {:reply, {age, Enum.count(new_children) }, { age, new_children }}
      else
        {:reply, {age, Enum.count(children) }, { age, children } }
      end
    end

    @impl true
    def handle_call(:population, _from, { age, children }) do
      count = Enum.reduce(children, 1, fn (pid, acc) -> acc + Lanternfish.population(pid) end)
      {:reply, count, { age, children } }
    end

    def terminate(reason, state) do
      { _age, children } = state
      Enum.map(children, &(GenServer.stop( &1)) )
    end
  end

  def simulate(starting_state, days) do
    population  = String.split(starting_state, ",")
    |> Stream.map(&String.to_integer/1)
    |> Enum.map(fn (init_age) ->
      {:ok, pid} = Lanternfish.spawn_fish(init_age)
      pid
    end)

    Enum.each(1..days, fn (day) ->
      Enum.map(population, &Lanternfish.tick/1)
      count = Stream.map(population, &Lanternfish.population/1) |> Enum.sum
      IO.puts "#{day}: #{count}"
    end)

    count = Stream.map(population, &Lanternfish.population/1) |> Enum.sum

    Enum.map(population, &(GenServer.stop(&1)))

    count
  end
end
