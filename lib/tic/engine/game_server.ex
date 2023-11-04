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
  @spec make_move(String.t(), Player.t(), Integer.t()) :: Game.t()
  def make_move(game_name, player, cell) do
    GenServer.call(via_tuple(game_name), {:make_move, player, cell})
  end

  @spec make_move(any(), Tic.Player.t()) :: Game.t()
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
    case Registry.lookup(@game_registry, game_name) do
      [{pid, nil}] -> pid
      [] -> nil
    end
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
     |> Game.new(player)}
  end

  def handle_call({:join, player}, _from, game) do
    with %{x: x, o: o} when not is_nil(x) and is_nil(o) <- game do
      updated_game =
        game
        |> Game.put_player(player.symbol, player)
        |> Game.set_status(:ready)

      {:reply, {:ok, updated_game}, updated_game}
    else
      _ ->
        {:reply, {:error, "Game has two players already"}, game}
    end
  end

  def handle_call({:make_move, player, cell}, _from, game) do
    with %{symbol: players_symbol} <- player,
         %{next: next_turn} <- game do
      cond do
        players_symbol == next_turn ->
          updated = Game.make_move(game, player.symbol, cell)

          updated =
            case updated.winner do
              %Player{symbol: :x} ->
                %Game{updated | x: Player.increment_streak(player)}

              %Player{symbol: :o} ->
                %Game{updated | o: Player.increment_streak(player)}

              nil ->
                updated
            end

          {:reply, updated, updated}

        true ->
          {:reply, game, game}
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
