defmodule Tic.GameServerTest do
  use ExUnit.Case

  alias Tic.{Board, Player, Game, GameServer}

  @game_name "ninja-game"
  @sam %Player{name: "Sam"}
  @jane %Player{name: "Jane", symbol: :o}
  @ai_player %Player{name: "AI", type: :computer, symbol: :o}

  setup do
    start_game_server(@sam)

    :ok
  end

  test "Jane joins as a second player, returns :ok, with game status :ready" do
    assert GameServer.join(@game_name, @jane) ==
             {:ok,
              %Game{
                name: @game_name,
                x: @sam,
                o: @jane,
                status: :ready
              }}
  end

  test "Jane can't join if there are two players already" do
    GameServer.join(@game_name, @ai_player)

    assert GameServer.join(@game_name, @jane) ==
             {:error, "Game has two players already"}
  end

  test "Sam makes a move to cell 5" do
    expected_board = %Tic.Board{
      cells: %{
        1 => nil,
        2 => nil,
        3 => nil,
        4 => nil,
        5 => :x,
        6 => nil,
        7 => nil,
        8 => nil,
        9 => nil
      }
    }

    expected_result = %Game{
      name: @game_name,
      x: @sam,
      o: nil,
      board: expected_board,
      round: 1,
      status: :in_progress,
      next: :o
    }

    assert GameServer.make_move(@game_name, @sam, 5) == expected_result
  end

  test "AI makes a move to cell 1" do
    %{board: board} = GameServer.make_move(@game_name, @ai_player)

    assert Enum.any?(board.cells, &(elem(&1, 1) == :o)) == true
  end

  test "it's a tie" do
    GameServer.join(@game_name, @jane)
    GameServer.make_move(@game_name, @sam, 5)
    GameServer.make_move(@game_name, @jane, 1)
    GameServer.make_move(@game_name, @sam, 3)
    GameServer.make_move(@game_name, @jane, 7)
    GameServer.make_move(@game_name, @sam, 4)
    GameServer.make_move(@game_name, @jane, 6)
    GameServer.make_move(@game_name, @sam, 8)
    GameServer.make_move(@game_name, @jane, 2)
    GameServer.make_move(@game_name, @sam, 9)

    assert GameServer.get_state(@game_name) == %Game{
             name: "ninja-game",
             x: @sam,
             o: @jane,
             board: %Tic.Board{
               cells: %{
                 1 => :o,
                 2 => :o,
                 3 => :x,
                 4 => :x,
                 5 => :x,
                 6 => :o,
                 7 => :o,
                 8 => :x,
                 9 => :x
               }
             },
             round: 9,
             status: :tie,
             winner: nil,
             strike: [],
             next: nil,
             finished: true
           }
  end

  test "Sam won the game" do
    GameServer.join(@game_name, @jane)
    GameServer.make_move(@game_name, @sam, 5)
    GameServer.make_move(@game_name, @jane, 1)
    GameServer.make_move(@game_name, @sam, 2)
    GameServer.make_move(@game_name, @jane, 3)
    GameServer.make_move(@game_name, @sam, 8)

    assert GameServer.get_state(@game_name) == %Game{
             name: "ninja-game",
             x: %Player{@sam | streak: 1},
             o: @jane,
             board: %Tic.Board{
               cells: %{
                 1 => :o,
                 2 => :x,
                 3 => :o,
                 4 => nil,
                 5 => :x,
                 6 => nil,
                 7 => nil,
                 8 => :x,
                 9 => nil
               }
             },
             round: 5,
             status: :won,
             winner: @sam,
             strike: [2, 5, 8],
             next: nil,
             finished: true
           }
  end

  test "making a move when it's not the player's turn will be ignored" do
    unchanged_game = GameServer.get_state(@game_name)
    assert GameServer.make_move(@game_name, @jane, 1) == unchanged_game
  end

  test "resetting the game" do
    GameServer.join(@game_name, @ai_player)
    GameServer.make_move(@game_name, @sam, 1)
    GameServer.make_move(@game_name, @ai_player)

    assert GameServer.reset(@game_name) == %Game{
             name: @game_name,
             x: @sam,
             o: @ai_player,
             board: %Board{},
             status: :ready
           }
  end

  defp start_game_server(player) do
    child_spec = %{
      id: GameServer,
      start: {GameServer, :start_link, [@game_name, player]}
    }

    start_supervised!(child_spec)
  end
end
