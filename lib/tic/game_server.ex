defmodule Tic.GameServer do
  @type t :: pid()

  alias Tic.{Game, Player}

  use GenServer

  @game_registry Tic.GameRegistry

  ### client process

  @doc """
  Start a game with a name and the first player
  """
  def start_link(game_name, %Player{} = player) do
    GenServer.start_link(__MODULE__, [game_name, player], name: via_tuple(game_name))
  end

  # via_tuple - private function used to register players in the GameServer Registry
  defp via_tuple(game_name) do
    {:via, Registry, {@game_registry, game_name}}
  end

  @doc """
  Join player into the game
  """
  def join(game_name, %Player{} = player) do
    GenServer.call(via_tuple(game_name), {:join, player})
  end

  @doc """
  Make move for human player
  """
  @spec make_move(String.t(), Player.t(), :integer) :: Game.t()
  def make_move(game_name, player, cell) do
    GenServer.call(via_tuple(game_name), {:make_move, player, cell})
  end

  @doc """
  Make move for computer player
  """
  def make_move(game_name, %Player{type: :computer} = player) do
    GenServer.call(via_tuple(game_name), {:make_move, player})
  end

  @spec status(String.t()) :: Game.t()
  def status(game_name) do
    GenServer.call(via_tuple(game_name), {:status})
  end

  def get_pid(game_name) do
    [{pid, nil}] = Registry.lookup(@game_registry, game_name)
    pid
  end

  def reset(game_name) do
    GenServer.call(via_tuple(game_name), {:reset})
  end

  ### server process

  @doc """
  Callback: initialize a new game with the given human player and a default AI player as the second player
  """
  def init([name, player]) do
    {:ok,
     name
     |> Game.new(player)
     |> Game.put_player(:o, %Player{name: "AI", type: :computer, symbol: :o})}
  end

  def handle_call({:join, player}, _from, game) do
    updated_game = Game.put_player(game, player.symbol, player)
    {:reply, updated_game, updated_game}
  end

  def handle_call({:make_move, player, cell}, _from, game) do
    with %{symbol: players_symbol} <- player,
         %{next: next_turn} <- game do
      cond do
        players_symbol == next_turn ->
          updated_game = Game.make_move(game, player.symbol, cell)
          {:reply, updated_game, updated_game}

        true ->
          {:reply, {:error, "Not player's turn"}, game}
      end
    end
  end

  def handle_call({:make_move, %Player{type: :computer, symbol: symbol}}, _from, game) do
    cell = Tic.AI.calculate_move(game.board, symbol)
    updated_game = Game.make_move(game, symbol, cell)
    {:reply, updated_game, updated_game}
  end

  def handle_call({:status}, _from, game) do
    {:reply, Game.status(game), game}
  end

  def handle_call({:reset}, _from, game) do
    reset_game = Game.reset(game)
    {:reply, reset_game, reset_game}
  end
end
