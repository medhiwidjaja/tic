defmodule Tic.AI do
  @moduledoc """
  This contains a very simplistic calculation of the next move.
  It only chooses a random empty cell.
  """

  @spec calculate_move(any(), any()) :: any()
  def calculate_move(%{cells: cells}, symbol) do
    find_best_move(cells, symbol)
  end

  # TODO: add better calculation
  defp find_best_move(board, _symbol), do: random_move(board)

  defp random_move(board) do
    board
    |> Enum.filter(&(elem(&1, 1) == nil))
    |> Enum.random()
    |> elem(0)
  end
end
