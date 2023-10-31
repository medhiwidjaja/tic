defmodule Tic.Board do
  @moduledoc """
  Game Board struct and methods to put symbol into the board, and determine the game result
  """

  @type t :: %__MODULE__{cells: map()}

  defstruct(
    cells: %{
      1 => nil,
      2 => nil,
      3 => nil,
      4 => nil,
      5 => nil,
      6 => nil,
      7 => nil,
      8 => nil,
      9 => nil
    }
  )

  @symbols [:x, :o]

  @doc """
  Put a symbol in one of the board's cell. Returns :error if the position is filled already.

  ## Examples

      iex> Tic.Board.put(%Tic.Board{}, 1, :x)
      %Tic.Board{cells: %{1 => :x, 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil, 7 => nil, 8 => nil, 9 => nil}}

      iex> Tic.Board.put(%Tic.Board{}, 9, :o)
      %Tic.Board{cells: %{1 => nil, 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil, 7 => nil, 8 => nil, 9 => :o}}

      iex> board = %Tic.Board{cells: %{1 => nil, 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil, 7 => nil, 8 => nil, 9 => :o}}
      iex> Tic.Board.put(board, 9, :x)
      :error
  """
  def put(%__MODULE__{cells: cells} = board, pos, symbol)
      when pos >= 1 and pos <= 9 and symbol in @symbols do
    with nil <- cells[pos] do
      %__MODULE__{board | cells: %{cells | pos => symbol}}
    else
      _ -> :error
    end
  end

  @doc """
  Checks if the board is full

  ## Examples

      iex> board = %Tic.Board{cells: %{1 => :x, 2 => :o, 3 => :x, 4 => :o, 5 => :x, 6 => :o, 7 => :x, 8 => :o, 9 => :x}}
      iex> Tic.Board.full?(board)
      true

      iex> board = %Tic.Board{cells: %{1 => nil, 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil, 7 => nil, 8 => nil, 9 => nil}}
      iex> Tic.Board.full?(board)
      false

  """
  def full?(%__MODULE__{cells: cells}) do
    Enum.all?(cells, fn {_, v} -> v end)
  end

  @doc """
  Checks if there's a winner.
  Returns nil if no winner, {winning_symbol, row} if there's a winner, or :tie if the game is a tie

  ## Examples

      iex> board = %Tic.Board{cells: %{1 => :x, 2 => :x, 3 => :x, 4 => :o, 5 => nil, 6 => nil, 7 => :o, 8 => nil, 9 => nil}}
      iex> Tic.Board.check_winner(board)
      {:x, [1,2,3]}

      iex> board = %Tic.Board{cells: %{1 => :o, 2 => nil, 3 => :x, 4 => :x, 5 => :o, 6 => :x, 7 => :o, 8 => nil, 9 => :o}}
      iex> Tic.Board.check_winner(board)
      {:o, [1,5,9]}

      iex> board = %Tic.Board{cells: %{1 => nil, 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil, 7 => nil, 8 => nil, 9 => nil}}
      iex> Tic.Board.check_winner(board)
      nil

      iex> board = %Tic.Board{cells: %{1 => :x, 2 => :o, 3 => :x, 4 => :o, 5 => :x, 6 => :o, 7 => :o, 8 => :x, 9 => :o}}
      iex> Tic.Board.check_winner(board)
      :tie
  """
  def check_winner(%__MODULE__{cells: cells} = board) do
    case check(cells) do
      nil -> if full?(board), do: :tie, else: nil
      win -> win
    end
  end

  ### Top row win
  defp check(%{
         1 => symbol,
         2 => symbol,
         3 => symbol,
         4 => _,
         5 => _,
         6 => _,
         7 => _,
         8 => _,
         9 => _
       })
       when symbol in @symbols,
       do: {symbol, [1, 2, 3]}

  # Middle row win
  defp check(%{
         1 => _,
         2 => _,
         3 => _,
         4 => symbol,
         5 => symbol,
         6 => symbol,
         7 => _,
         8 => _,
         9 => _
       })
       when symbol in @symbols,
       do: {symbol, :row2}

  # Bottom row win
  defp check(%{
         1 => _,
         2 => _,
         3 => _,
         4 => _,
         5 => _,
         6 => _,
         7 => symbol,
         8 => symbol,
         9 => symbol
       })
       when symbol in @symbols,
       do: {symbol, [4, 5, 6]}

  # Left column win
  defp check(%{
         1 => symbol,
         2 => _,
         3 => _,
         4 => symbol,
         5 => _,
         6 => _,
         7 => symbol,
         8 => _,
         9 => _
       })
       when symbol in @symbols,
       do: {symbol, [1, 4, 7]}

  # Middle column win
  defp check(%{
         1 => _,
         2 => symbol,
         3 => _,
         4 => _,
         5 => symbol,
         6 => _,
         7 => _,
         8 => symbol,
         9 => _
       })
       when symbol in @symbols,
       do: {symbol, [2, 5, 8]}

  # Right column
  defp check(%{
         1 => _,
         2 => _,
         3 => symbol,
         4 => _,
         5 => _,
         6 => symbol,
         7 => _,
         8 => _,
         9 => symbol
       })
       when symbol in @symbols,
       do: {symbol, [3, 6, 9]}

  # Diagonal 1, top left -> bottom right
  defp check(%{
         1 => symbol,
         2 => _,
         3 => _,
         4 => _,
         5 => symbol,
         6 => _,
         7 => _,
         8 => _,
         9 => symbol
       })
       when symbol in @symbols,
       do: {symbol, [1, 5, 9]}

  # Diagonal 2, top right -> bottom left
  defp check(%{
         1 => _,
         2 => _,
         3 => symbol,
         4 => _,
         5 => symbol,
         6 => _,
         7 => symbol,
         8 => _,
         9 => _
       })
       when symbol in @symbols,
       do: {symbol, [3, 5, 7]}

  defp check(_), do: nil
end
