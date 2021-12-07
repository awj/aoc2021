defmodule Day4 do
  defmodule Board do
    defstruct contents: [], width: 0

    def new(lines) do
      contents = Enum.map(lines, fn (line) ->
        String.split(line)
        |> Enum.map(&({String.to_integer(&1), false}))
      end)

      width = length(List.first(contents))

      %Board{
        contents: contents,
        width: width
      }
    end

    def winner?(board) do
      row_winner?(board) || column_winner?(board)
    end

    def row_winner?(board) do
      Enum.any?(board.contents, fn (row) ->
        Enum.all?(row, fn ({_, marked}) -> marked end)
      end)
    end

    def column_winner?(board) do
      Enum.any?((1..board.width), fn (i) ->
        Enum.all?(board.contents, fn (row) ->
          {_, marked} = Enum.at(row, i-1)
          marked
        end)
      end)
    end

    def score(board, latest) do
      Enum.reduce(board.contents, 0, fn (row, acc) ->
        Enum.reduce(row, acc, fn ({val, marked}, acc) ->
          if marked do
            acc
          else
            acc + val
          end
        end)
      end) * latest
    end

    def mark(board, number) do
      new_contents = Enum.map(board.contents, fn (row) ->
        Enum.map(row, fn ({num, state}) ->
          new_state = if num == number, do: true, else: state
          {num, new_state}
        end)
      end)

      %Board{ contents: new_contents, width: board.width }
    end
  end

  defmodule Game do
    defstruct boards: [], numbers: []

    def new(input) do
      lines = String.split(input, "\n")

      numbers = List.first(lines) |> String.split(",") |> Enum.map(&String.to_integer/1)

      board_lines = tl(tl(lines))

      chunk_fun = fn line, state ->
        if line == "" do
          {:cont, Board.new(state), []}
        else
          {:cont, state ++ [line]}
        end
      end

      after_fun = fn _ ->
        {:cont, []}
      end

      boards = Enum.chunk_while(board_lines, [], chunk_fun, after_fun)

      %Game{numbers: numbers, boards: boards}
    end

    def winning_score(game) do
      next_number = hd(game.numbers)

      updated_boards = Enum.map(game.boards, fn (board) ->
        Board.mark(board, next_number)
      end)

      winner = Enum.find(updated_boards, &Board.winner?/1)

      if winner != nil do
        IO.inspect(winner, label: "winner")
        IO.inspect(next_number, label: "number")
        Board.score(winner, next_number)
      else
        winning_score(%Game{ numbers: tl(game.numbers), boards: updated_boards })
      end
    end

    def all_winners(game, winning_boards \\ []) do
      next_number = hd(game.numbers)

      updated_boards = Enum.map(game.boards, fn (board) ->
        Board.mark(board, next_number)
      end)

      {winners, remaining} = Enum.split_with(updated_boards, &Board.winner?/1)

      IO.inspect(next_number, label: "next")
      IO.inspect(winners, label: "new winners")
      new_winners = winning_boards ++ Enum.map(winners, &(Board.score(&1, next_number)))

      if length(tl(game.numbers)) == 0 do
        new_winners
      else
        all_winners(%Game{ numbers: tl(game.numbers), boards: remaining }, new_winners)
      end
    end
  end
end
