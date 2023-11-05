defmodule Tic.TicTest do
  use ExUnit.Case, async: true

  alias Tic.{GameSupervisor, GameServer, Board, Player}

  setup do
    player = %Player{name: "Sam"}
    player2 = %Player{name: "Jane", symbol: :o}

    {:ok, %{player: player, player2: player2}}
  end

  test "new/2 creates a game under the supervisor", %{player: player} do
    %{active: active} = DynamicSupervisor.count_children(GameSupervisor)
    Tic.new_game("new game", player)
    %{active: new_active} = DynamicSupervisor.count_children(GameSupervisor)
    assert_in_delta active, new_active, 1
  end

  test "active_games returns a list of the names of running games", %{player: player} do
    Tic.new_game("sam-duel", player)

    active_games = Tic.active_games()

    assert "sam-duel" in active_games
  end

  test "sets new status to the game", %{player: player} do
    name = "new-status-game"
    Tic.new_game(name, player)
    game_state = Tic.get_state(name)
    assert game_state.status == :init

    Tic.set_status(name, :ready)
    game_state = Tic.get_state(name)

    assert game_state.status == :ready
  end

  test "gets the status of the game", %{player: player} do
    name = "get-status-game"
    Tic.new_game(name, player)
    assert :init == Tic.get_status(name)
  end

  test "make a move", %{player: player, player2: player2} do
    name = "ninja-game"
    Tic.new_game(name, player)
    Tic.join(name, player2)
    Tic.set_status(name, :in_progress)

    assert Tic.get_status(name) == :in_progress

    Tic.make_move(name, :x, "1")
    %{board: %{cells: cells}, status: status, next: next} = Tic.get_state(name)

    assert status == :in_progress
    assert %{1 => :x} = cells
    assert next == :o
  end
end
