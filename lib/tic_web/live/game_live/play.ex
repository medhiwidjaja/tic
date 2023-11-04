defmodule TicWeb.GameLive.Play do
  use TicWeb, :live_view

  on_mount TicWeb.UserLiveAuth
  @topic_prefix "game:"

  @impl true
  def mount(params, _session, socket) do
    game_name = params["id"]

    game_names = Tic.active_games()

    if Enum.member?(game_names, game_name) do
      game_state = Tic.status(game_name)
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
          # Phoenix.PubSub.subscribe(Tic.PubSub, "game:#{game_name}")
          TicWeb.GameChannel.subscribe("game:#{game_name}")

          {:ok,
           socket
           |> assign(:game_name, game_name)
           |> assign(:next, game_state.next)
           |> assign(:game_status, game_state.status)
           |> assign(:current_user, current_user)
           |> assign(:player, signed_in_player)
           |> assign(:active_games, Tic.active_games())
           |> assign(:game, game_state)}
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
        "make-move",
        %{"player" => symbol, "cell" => cell},
        %{assigns: %{game_name: game_name}} = socket
      ) do
    game =
      game_name
      |> Tic.make_move(symbol, cell)
      |> maybe_make_computer_move()

    broadcast_update(game)

    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_event("reset", _, %{assigns: %{game_name: game_name}} = socket) do
    game = Tic.GameServer.reset(game_name)
    broadcast_update(game)
    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_event("start", _, %{assigns: %{game_name: game_name}} = socket) do
    game =
      game_name
      |> Tic.GameServer.status()
      |> Tic.Game.set_status(:in_progress)

    game = shuffle_players(game)

    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:game_status, game.status)}
  end

  @impl true
  def handle_event(
        "join",
        %{"player" => name},
        %{assigns: %{game_name: game_name}} = socket
      ) do
    user = Tic.Users.get_user_by_name(name)
    player = %Tic.Player{name: user.name, id: user.id, symbol: :o}

    case Tic.GameServer.join(game_name, player) do
      {:ok, game} ->
        broadcast_update(game)

        {:noreply, assign(socket, :game, game)}

      {:error, error_message} ->
        {:noreply,
         socket
         |> put_flash(:error, error_message)}
    end
  end

  @doc """
  Info event handler to update the game based on message from every move
  """

  # @impl true
  # def handle_info({:update, %{game: game, game_status: game_status}}, socket) do
  #   {:noreply,
  #    socket
  #    |> assign(:game, game)
  #    |> assign(:game_status, game_status)}
  # end

  @impl true
  def handle_info(%{event: "update", payload: %{game: game, game_status: game_status}}, socket) do
    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:game_status, game_status)}
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
    broadcast_update(game)
    game
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

  defp broadcast_update(game) do
    TicWeb.GameChannel.broadcast!(@topic_prefix <> game.name, "update", %{
      game: game,
      game_status: game.status
    })

    # Phoenix.PubSub.broadcast_from!(Tic.PubSub, self(), topic, payload)
  end

  defp disable_move?(game, nil), do: true

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
