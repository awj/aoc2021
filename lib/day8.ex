defmodule Day8 do

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&Day8.parse_line/1)
  end

  def parse_line(line) do
    [signal_text, output_text] = String.split(line, " | ")

    {
      String.split(signal_text),
      String.split(output_text)
    }
  end

  def count_uniques(output) do
    IO.inspect(output, label: "count arg")
    Enum.count(output, fn (item) ->
      length = String.length(item)

      Enum.member?([
        2, # 1 digit
        4, # 4 digit
        3, # 7 digit
        7, # 8 digit
      ],
        length
      )
    end)
  end

  def unique_outputs(content) do
    Enum.reduce(content, 0, fn ({_, outputs}, acc) ->
      acc + Day8.count_uniques(outputs)
    end)
  end
end
