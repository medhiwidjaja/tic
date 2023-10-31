defmodule TicWeb.GameLive.Show do
  use TicWeb, :live_view

  # alias Tic.{Game, Player}

  @impl true
  def mount(params, _session, socket) do
    game_name = params["id"]

    if Enum.member?(Tic.active_games(), game_name) do
      game_state = Tic.status(game_name)
      Phoenix.PubSub.subscribe(Tic.PubSub, "game:#{game_name}")

      {:ok,
       socket
       |> assign(:game_name, game_name)
       |> assign(:turn, game_state.next)
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
        %{"symbol" => symbol, "cell" => cell},
        %{assigns: %{game_name: game_name}} = socket
      ) do
    updated_game = Tic.make_move(game_name, symbol, cell)

    broadcast_update("game:#{game_name}", {:update, %{game: updated_game}})

    # updated_game = next_turn(updated_game)

    {:noreply, assign(socket, :game, updated_game)}
  end

  @impl true
  def handle_event("reset", _, %{assigns: %{game_name: game_name}} = socket) do
    game = Tic.GameServer.reset(game_name)
    broadcast_update("game:#{game.id}", {:update, %{game: game}})
    {:noreply, assign(socket, :game, game)}
  end

  defp next_turn(%{finished: true} = game), do: game

  defp next_turn(game) do
    updated_game = Tic.GameServer.make_move(game.id, game.turn)
    broadcast_update("game:#{game.id}", {:update, %{game: updated_game}})
    updated_game
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
  def handle_info({:accepted, %{game: game}}, socket) do
    {:noreply,
     socket
     |> assign(:game, game)}
  end

  defp broadcast_update(topic, payload) do
    Phoenix.PubSub.broadcast_from!(Tic.PubSub, self(), topic, payload)
  end

  defp disable_move?(game, player) do
    game.finished || !player_turn?(game, player)
  end

  defp player_turn?(%{next: next}, player) do
    player.symbol == next
  end
end
