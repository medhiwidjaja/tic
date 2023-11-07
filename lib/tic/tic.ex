defmodule Tic do
  @moduledoc """
  Tic keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Tic.GameSupervisor
  alias Tic.GameServer
  alias Tic.Game

  @doc """
  Creates a new supervised game process with the supplied name and player.
  """
  defdelegate new_game(name, player), to: GameSupervisor, as: :create_game

  @doc """
  Joins a new player as :o in the running game process with the supplied game_name
  """
  defdelegate join(game_name, player), to: GameServer

  @doc """
  Sets the game to a new status
  """
  defdelegate set_status(game_name, new_status), to: GameServer

  @doc """
  Get the game status
  """
  def get_status(game_name) do
    get_state(game_name).status
  end

  @doc """
  Puts the symbol on the cell
  """
  def make_move(game_name, symbol, cell) do
    player =
      game_name
      |> GameServer.get_state()
      |> Game.get_player(symbol)

    GameServer.make_move(game_name, player, String.to_integer(cell))
  end

  @doc """
  Lists the active games from the supervisor
  """
  @spec active_games() :: list()
  defdelegate active_games(), to: GameSupervisor

  @doc """
  Get the game state based on the supplied game_name
  """
  @spec get_state(String.t()) :: Game.t()
  defdelegate get_state(game_name), to: GameServer

  @doc """
  Reset the game to :ready state and blank board. Existing players are retained.
  """
  defdelegate reset(game_name), to: GameServer
end
