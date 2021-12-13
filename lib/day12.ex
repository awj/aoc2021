defmodule Day12 do
  defmodule PathFragment do
    defstruct path: [], small_caves: MapSet.new([]), steps: MapSet.new([]), double_pass: "", double_pass_happened: false

    def new({origin, destination}, double_pass \\ "") do
      small_caves = Enum.filter([origin, destination], fn (location) -> Day12.small_cave?(location) end)
      %PathFragment{
        path: [origin, destination],
        small_caves: MapSet.new(small_caves),
        steps: MapSet.new([{origin, destination}]),
        double_pass: double_pass
      }
    end

    def debug(fragment) do
      Enum.join(fragment.path, ",")
    end

    def can_add?(fragment, {start, dest} = step) when fragment.double_pass_happened == false and fragment.double_pass == start do
      head = hd(fragment.path)
      dest == head
    end

    def can_add?(fragment, {start, dest} = step) do
      head = hd(fragment.path)
      cond do
        MapSet.member?(fragment.small_caves, start) -> false
        true -> dest == head
      end
    end

    def add(fragment, prior_step) when fragment.double_pass == prior_step and fragment.double_pass_happened == false do
      %PathFragment{
        fragment |
        path: [prior_step | fragment.path],
        double_pass_happened: true
      }
    end

    def add(fragment, prior_step) do
      %PathFragment{
        fragment |
        path: [prior_step | fragment.path],
        small_caves: mark_small_cave(fragment.small_caves, prior_step),
        steps: MapSet.put(fragment.steps, {prior_step, hd(fragment.path)}),
      }
    end

    def mark_small_cave(caves, new_cave) do
      if Day12.small_cave?(new_cave) do
        MapSet.put(caves, new_cave)
      else
        caves
      end
    end

    def complete?(fragment) do
      hd(fragment.path) == "start"
    end
  end

  def small_cave?(cave) do
    String.match?(cave, ~r/[a-z]+/)
  end

  def parse(input) do
    String.split(input)
    |> Enum.map(fn (line) ->
      [starting, ending] = String.split(line, "-")
      {starting, ending}
    end)
  end

  def seed_paths(steps) do
    location_names = Enum.map(steps, &Tuple.to_list/1) |> List.flatten |> Enum.uniq

    passable_small_caves = Enum.filter(location_names, fn
      "start" -> false
      "end" -> false
      cave -> small_cave?(cave)
    end)

    seeds = for step <- steps,
        {_origin, destination} = dir <- bidirectional(step),
      double_passee <- passable_small_caves,
      destination == "end" do
        PathFragment.new(dir, double_passee)
    end

    Enum.uniq_by(seeds, fn (seed) -> {seed.double_pass, hd(seed.path)} end)
  end

  def can_expand?(path, steps) do
    Enum.any?(steps, fn({origin, dest}) -> PathFragment.can_add?(path, {origin, dest}) || PathFragment.can_add?(path, {dest, origin}) end)
  end

  def grow(paths, steps) do
    for path <- paths,
        step <- steps,
        {origin, _dest} = dir <- bidirectional(step),
        PathFragment.can_add?(path, dir) do
          PathFragment.add(path, origin)
    end
  end

  def bidirectional({origin, dest}) do
    [
      {origin, dest},
      {dest, origin}
    ]
  end

  def fully_expand(working_paths, steps, complete_paths \\ [])

  def fully_expand([], _steps, complete_path) do
    Enum.uniq_by(complete_path, fn (fragment) -> fragment.path end)
  end

  def fully_expand(working_paths, steps, complete_paths) do
    grown = grow(working_paths, steps)

    {growable, finished} = Enum.split_with(grown, fn (path) -> can_expand?(path, steps) end)

    new_completions = Enum.filter(grown, &PathFragment.complete?/1)

    IO.inspect(%{grown: Enum.count(grown), working: Enum.count(working_paths), complete: Enum.count(complete_paths), finished: Enum.count(finished), growable: Enum.count(growable)})

    fully_expand(growable, steps, Enum.concat(complete_paths, new_completions))
  end

  def count_paths(input) do
    steps = parse(input)
    seeds = seed_paths(steps)

    expanded = fully_expand(seeds, steps)

    expanded
    |> Enum.map(fn (fragment) -> PathFragment.debug(fragment) end)
    |> Enum.sort
    |> Enum.map(&(IO.inspect(&1)))

    Enum.count(
      expanded
    )
  end
end
