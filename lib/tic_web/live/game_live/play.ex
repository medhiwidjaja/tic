defmodule TicWeb.GameLive.Play do
  use TicWeb, :live_view

  alias Tic.{Game, GameServer}
  alias TicWeb.GameChannel

  on_mount TicWeb.UserLiveAuth
  @topic_prefix "game:"

  @impl true
  def mount(params, _session, socket) do
    game_name = params["id"]

    game_names = Tic.active_games()

    if Enum.member?(game_names, game_name) do
      game_state = Tic.get_state(game_name)
      current_user = socket.assigns.current_user
      signed_in_player = signed_in_player(game_state, current_user)

      with %{x: x} when not is_nil(x) <- game_state,
           %{o: o} when not is_nil(o) <- game_state,
           player <- signed_in_player,
           false <- x == player || o == player do
        {:ok,
         socket
         |> put_flash(
           :error,
           "Sorry, this game has 2 players already. You may watch and make comments"
         )
         |> push_navigate(to: ~p"/games/#{game_name}")}
      else
        _ ->
          GameChannel.subscribe("game:#{game_name}")

          {:ok,
           socket
           |> assign(:game_name, game_name)
           |> assign(:next, game_state.next)
           |> assign(:game_status, game_state.status)
           |> assign(:current_user, current_user)
           |> assign(:player, signed_in_player)
           |> assign(:active_games, Tic.active_games())
           |> assign(:game, game_state)
           |> assign(:player_x, game_state.x && game_state.x.name)
           |> assign(:player_o, game_state.o && game_state.o.name)}
      end
    else
      {:ok,
       socket
       |> put_flash(:error, "Game couldn't be found")
       |> push_navigate(to: ~p"/games")}
    end
  end

  # Callbacks

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "join",
        %{"player" => name},
        %{assigns: %{game_name: game_name}} = socket
      ) do
    user = Tic.Users.get_user_by_name(name)
    player = %Tic.Player{name: user.name, id: user.id, symbol: :o}

    case Tic.join(game_name, player) do
      {:ok, game} ->
        broadcast("accept", game)

        {:noreply,
         socket
         |> assign(:game, game)
         |> assign(:player, player)}

      {:error, error_message} ->
        {:noreply,
         socket
         |> put_flash(:error, error_message)}
    end
  end

  @impl true
  def handle_event("start", _, %{assigns: %{game_name: game_name}} = socket) do
    Tic.set_status(game_name, :ready)
    game = Tic.get_state(game_name)
    broadcast("update", game)
    Process.send_after(self(), %{event: "shuffle", payload: %{game: game}}, 3000)

    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:game_status, game.status)}
  end

  @impl true
  def handle_event(
        "make-move",
        %{"player" => symbol, "cell" => cell},
        %{assigns: %{game_name: game_name}} = socket
      ) do
    socket.assigns.game

    game =
      game_name
      |> Tic.make_move(symbol, cell)
      |> maybe_make_computer_move()

    broadcast("update", game)

    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_event("reset", _, %{assigns: %{game_name: game_name}} = socket) do
    game = Tic.reset(game_name)

    broadcast("update", game)
    Process.send_after(self(), %{event: "shuffle", payload: %{game: game}}, 3000)

    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:game_status, game.status)}
  end

  @doc """
  "update" event handler to update the game based on message from every move

  "accept" event handler to accepted messsage by the second player

  "shuffle" event handler to shuffles the players
  """
  @impl true
  def handle_info(%{event: "update", payload: %{game: game}}, socket) do
    signed_in_player = signed_in_player(game, socket.assigns.current_user)

    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:game_status, game.status)
     |> assign(:player_x, game.x.name)
     |> assign(:player_o, game.o.name)
     |> assign(:player, signed_in_player)}
  end

  @impl true
  def handle_info(%{event: "accept", payload: %{game: game}}, socket) do
    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:player_o, game.o.name)
     |> assign(:game_status, game.status)}
  end

  @impl true
  def handle_info(%{event: "shuffle", payload: %{game: game}}, socket) do
    Tic.set_status(game.name, :in_progress)
    updated_game = GameServer.shuffle_players(game.name)
    broadcast("update", updated_game)

    {:noreply, socket}
  end

  defp maybe_make_computer_move(game) do
    player = Game.get_player(game, game.next)

    if player && player.type == :computer do
      GameServer.make_move(game.name, player)
    else
      game
    end
  end

  defp broadcast(event, game) do
    GameChannel.broadcast!(@topic_prefix <> game.name, event, %{game: game})
  end

  defp signed_in_player(game, current_user) do
    xid = game.x && game.x.id
    oid = game.o && game.o.id

    case current_user.id do
      ^xid -> game.x
      ^oid -> game.o
      _ -> nil
    end
  end

  defdelegate disable_move?(game, player), to: Game
end
