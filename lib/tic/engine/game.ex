defmodule Tic.Game do
  @moduledoc """
  Game struct and functions to change and query the game state
  """

  alias Tic.Board

  @type t :: %__MODULE__{
          name: String.t(),
          x: any(),
          o: any(),
          status: :init | :in_progress | :ready | :challenge | :accepted | :won | :tie,
          board: Board.t(),
          round: integer(),
          next: atom(),
          winner: any(),
          strike: list(),
          finished: boolean()
        }

  @initial_board %Board{}

  defstruct(
    name: nil,
    x: nil,
    o: nil,
    status: :init,
    board: @initial_board,
    round: 0,
    next: :x,
    winner: nil,
    strike: [],
    finished: false
  )

  @doc """
  Returns a new game. It take a "name" and an optional player

  ## Examples

    iex> Tic.Game.new("energy-game", "Sam")
    %Tic.Game{name: "energy-game",
    x: "Sam",
    o: nil,
    status: :init,
    board: %Tic.Board{},
    round: 0,
    next: :x,
    winner: nil,
    strike: [],
    finished: false}
  """
  @spec new(String.t(), String.t() | nil) :: Tic.Game.t()
  def new(name, player \\ nil) do
    %__MODULE__{name: name, x: player}
  end

  @doc """
  Make a move on the game, by the player with the symbol on a position on the cells.
  Returns the updated game with the new state

  ## Examples:

    ## Move :x into cell no 1
    iex> game = Tic.Game.new("ninja")
    iex> Tic.Game.make_move(game, :x, 1)
    %Tic.Game{name: "ninja", next: :o, round: 1, board: %Tic.Board{cells: %{1 => :x, 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil, 7 => nil, 8 => nil, 9 => nil}}}

    ## Move in a finished game should return the original game
    iex> game = Tic.Game.new("game")
    iex> game = %Tic.Game{game | finished: true}
    iex> Tic.Game.make_move(game, :x, 1)
    game

    ## Move that results in a tie game
    iex> board = %Tic.Board{cells: %{1 => :x, 2 => :o, 3 => :x, 4 => :o, 5 => :x, 6 => :o, 7 => :o, 8 => :x, 9 => nil}}
    iex> game = %Tic.Game{board: board, round: 8, next: :o}
    iex> Tic.Game.make_move(game, :o, 9)
    %Tic.Game{finished: true, status: :tie, round: 9, next: nil, board: %{board | cells: %{board.cells | 9 => :o}}}

    ## Move that results in :x winning the game
    iex> board = %Tic.Board{cells: %{1 => :x, 2 => :x, 3 => nil, 4 => :o, 5 => nil, 6 => nil, 7 => :o, 8 => nil, 9 => nil}}
    iex> game = %Tic.Game{x: "Sam", board: board, round: 4, next: :x}
    iex> Tic.Game.make_move(game, :x, 3)
    %Tic.Game{x: "Sam", finished: true, status: :won, winner: "Sam", round: 5, strike: [1,2,3], next: nil, board: %{board | cells: %{board.cells | 3 => :x}}}

  """
  def make_move(%{finished: false, board: board} = game, symbol, pos) do
    updated_board = Board.put(board, pos, symbol)

    case Board.check_winner(updated_board) do
      nil ->
        %__MODULE__{game | board: updated_board, round: game.round + 1, next: next_turn(symbol)}

      :tie ->
        %__MODULE__{
          game
          | board: updated_board,
            round: game.round + 1,
            status: :tie,
            finished: true,
            next: nil
        }

      {symbol, strike} ->
        %__MODULE__{
          game
          | board: updated_board,
            round: game.round + 1,
            next: nil,
            finished: true,
            winner: get_player(game, symbol),
            strike: strike,
            status: :won
        }
    end
  end

  def make_move(game, _, _) do
    game
  end

  @doc """
  Returns the current state of the game
  """
  def status(game),
    do: %__MODULE__{
      name: game.name,
      x: game.x,
      o: game.o,
      status: game.status,
      board: game.board,
      round: game.round,
      next: game.next,
      winner: game.winner,
      strike: game.strike,
      finished: game.finished
    }

  @doc """
  Set stage of the game

  ## Examples

    iex> %{status: status} = Tic.Game.set_status(%Tic.Game{}, :ready)
    iex> status
    :ready
  """
  def set_status(game, new_status), do: %__MODULE__{game | status: new_status}

  @doc """
  Put a player into position for the symbol

  ## Examples

    iex> Tic.Game.put_player(%Tic.Game{}, :x, "Sam")
    %Tic.Game{x: "Sam"}

    iex> Tic.Game.put_player(%Tic.Game{}, :o, "Jane")
    %Tic.Game{o: "Jane"}
  """
  def put_player(game, :x, player), do: %__MODULE__{game | x: player}
  def put_player(game, :o, player), do: %__MODULE__{game | o: player}

  @doc """
  Get a player by the symbol, either an atom or a string (used in the template)

  ## Examples

    iex> Tic.Game.get_player(%Tic.Game{x: %{name: "Sam"}}, :x)
    %{name: "Sam"}

    iex> Tic.Game.get_player(%Tic.Game{o: %Tic.Player{name: "Jane"}}, "o")
    %Tic.Player{name: "Jane", id: nil, streak: 0, symbol: :x, type: :human}
  """
  def get_player(game, "x"), do: game.x
  def get_player(game, "o"), do: game.o
  def get_player(game, :x), do: game.x
  def get_player(game, :o), do: game.o
  def get_player(_, _), do: nil

  defp next_turn(:x), do: :o
  defp next_turn(:o), do: :x

  @doc """
  Reset the game retaining the players, and setting the status to :ready
  This is needed for two players who want to reset the game from the start

  ## Examples

    iex> game = %Tic.Game{x: "Sam", o: "Jack", status: :in_progress, round: 4}
    iex> Tic.Game.reset(game)
    %Tic.Game{x: "Sam", o: "Jack", status: :ready, round: 0}

  """
  def reset(game),
    do: %__MODULE__{
      name: game.name,
      x: game.x,
      o: game.o,
      status: :ready,
      next: :x
    }

  @doc """
  Switch players
  """
  def switch_players(game) do
    x = %Tic.Player{game.o | symbol: :x}
    o = %Tic.Player{game.x | symbol: :o}

    %__MODULE__{game | x: o, o: x}
  end
end
