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

  defdelegate new_game(name, player), to: GameSupervisor, as: :create_game
  defdelegate join(game_name, player), to: GameServer

  def make_move(game_name, symbol, cell) do
    player =
      game_name
      |> GameServer.status()
      |> Game.get_player(symbol)

    GameServer.make_move(game_name, player, String.to_integer(cell))
  end

  @spec active_games() :: list()
  defdelegate active_games(), to: GameSupervisor

  @spec status(String.t()) :: Game.t()
  defdelegate status(game), to: GameServer
end
