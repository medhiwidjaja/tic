defmodule TicWeb.GameLive.Play do
  use TicWeb, :live_view

  on_mount TicWeb.UserLiveAuth

  # alias Tic.{Game, Player}

  @impl true
  def mount(params, _session, socket) do
    game_name = params["id"]

    game_names = Tic.active_games()

    if Enum.member?(game_names, game_name) do
      game_state = Tic.status(game_name)
      Phoenix.PubSub.subscribe(Tic.PubSub, "game:#{game_name}")
      TicWeb.GameChannel.subscribe("game:#{game_name}")

      {:ok,
       socket
       |> assign(:game_name, game_name)
       |> assign(:next, game_state.next)
       |> assign(:player, signed_in_player(game_state, socket.assigns.current_user))
       |> assign(:active_games, Tic.active_games())
       |> assign(:messages, [])
       |> assign(:text_input, "")
       |> assign(:game, game_state)}
    else
      {:ok,
       socket
       |> put_flash(:error, "Game couldn't be found")
       |> push_navigate(to: ~p"/games")}
    end
  end

  # Callbacks

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, params) do
    game_name = params["id"]
    game = Tic.status(game_name)

    socket
    |> assign(:game_name, game_name)
    |> assign(:turn, game.next)
    |> assign(:game, Tic.status(game_name))
  end

  defp apply_action(socket, :play, params) do
    game_name = params["id"]
    game = Tic.status(game_name)

    socket
    |> assign(:game_name, game_name)
    |> assign(:turn, game.next)
    |> assign(:game, Tic.status(game_name))
  end

  @impl true
  def handle_event(
        "make-move",
        %{"player" => symbol, "cell" => cell},
        %{assigns: %{game_name: game_name}} = socket
      ) do
    updated_game =
      game_name
      |> Tic.make_move(symbol, cell)
      |> maybe_make_computer_move()

    broadcast_update("game:#{game_name}", {:update, %{game: updated_game}})

    {:noreply, assign(socket, :game, updated_game)}
  end

  @impl true
  def handle_event("reset", _, %{assigns: %{game_name: game_name}} = socket) do
    game = Tic.GameServer.reset(game_name)
    broadcast_update("game:#{game.name}", {:update, %{game: game}})
    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_event(
        "join",
        %{"player" => name},
        %{assigns: %{game_name: game_name}} = socket
      ) do
    user = Tic.Users.get_user_by_name(name)
    player = %Tic.Player{name: user.name, id: user.id, symbol: :o}

    game =
      game_name
      |> Tic.GameServer.join(player)
      |> shuffle_players()

    broadcast_update("game:#{game_name}", {:update, %{game: game}})

    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_event(
        "send",
        %{"player" => name, "message" => value},
        %{assigns: %{game_name: game_name}} = socket
      ) do
    user = Tic.Users.get_user_by_name(name)
    player = %Tic.Player{name: user.name, id: user.id, symbol: :o}
    game = Tic.GameServer.join(game_name, player)

    broadcast_update("game:#{game_name}", {:update, %{game: game}})

    {:noreply, assign(socket, :game, game)}
  end

  @doc """
  Info event handler to update the game based on message from every move
  """
  @impl true
  def handle_info({:update, %{game: game}}, socket) do
    {:noreply,
     socket
     |> assign(:game, game)}
  end

  @impl true
  def handle_info(%{event: "chat", payload: %{"message" => message}}, socket) do
    messages = socket.assigns.messages ++ [message]

    {:noreply,
     socket
     |> assign(:messages, messages)}
  end

  @impl true
  def handle_info({:accepted, %{game: game}}, socket) do
    {:noreply,
     socket
     |> assign(:game, game)}
  end

  defp shuffle_players(game) do
    n = :rand.uniform(20)
    do_shuffle_players(game, n)
  end

  defp do_shuffle_players(game, 0), do: game

  defp do_shuffle_players(game, n_times) do
    :timer.sleep(100)
    do_shuffle_players(switch_players(game), n_times - 1)
  end

  defdelegate switch_players(game), to: Tic.Game

  defp maybe_make_computer_move(game) do
    player = Tic.Game.get_player(game, game.next)

    if player && player.type == :computer do
      Tic.GameServer.make_move(game.name, player)
    else
      game
    end
  end

  defp broadcast_update(topic, payload) do
    Phoenix.PubSub.broadcast_from!(Tic.PubSub, self(), topic, payload)
  end

  defp message(:won, winner, _turn) do
    "#{winner.name} won!"
  end

  defp message(:init, _, _), do: "Let's play a game!"
  defp message(:tie, _, _), do: "It's a tie"
  defp message(_, _, next), do: "#{next} plays next"

  defp disable_move?(game, player) do
    game.finished || !(game.status in [:ready, :in_progress]) ||
      game.next != player.symbol
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
end
