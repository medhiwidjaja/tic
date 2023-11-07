defmodule TicWeb.GameLive.Index do
  use TicWeb, :live_view

  alias Tic.{Player, Game, GameServer}
  alias TicWeb.GameChannel

  @game_demo "DemoGame"
  @topic_prefix "game:"

  @impl true
  def mount(_params, session, socket) do
    logged_in? = Map.has_key?(session, "user_token")
    current_user = logged_in? && Tic.Users.get_user_by_session_token(session["user_token"])

    GameChannel.subscribe(@topic_prefix <> @game_demo)

    socket = init_game() |> init_assigns(socket)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:active_games, Tic.active_games() |> Enum.map(&GameServer.get_state/1))
     |> assign(:logged_in, logged_in?)}
  end

  # Callbacks

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:games, Enum.map(Tic.active_games(), & &1))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Game")
    |> assign(:games, Enum.map(Tic.active_games(), & &1))
  end

  @impl true
  def handle_event("start-demo", _, socket) do
    game_state = init_game()
    Tic.set_status(@game_demo, :in_progress)
    Process.send_after(self(), "ai-move", 500)

    {:noreply, init_assigns(game_state, socket)}
  end

  defp init_game() do
    ai_player1 = %Player{name: "AI 1", type: :computer, symbol: :x}
    ai_player2 = %Player{name: "AI 2", type: :computer, symbol: :o}
    Tic.new_game(@game_demo, ai_player1)
    Tic.join(@game_demo, ai_player2)
    Tic.reset(@game_demo, :init)
  end

  defp init_assigns(game_state, socket) do
    socket
    |> assign(:game, game_state)
    |> assign(:player_x, game_state.x && game_state.x.name)
    |> assign(:player_o, game_state.o && game_state.o.name)
    |> assign(:player, Game.get_next_player(game_state))
  end

  @impl true
  def handle_info("ai-move", %{assigns: %{game: game, player: player}} = socket) do
    game = GameServer.make_move(game.name, player)
    Process.sleep(500)
    GameChannel.broadcast!(@topic_prefix <> @game_demo, "update", %{game: game})

    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_info(%{event: "update", payload: %{game: game}}, socket) do
    if !game.finished, do: Process.send_after(self(), "ai-move", 1000)

    {:noreply, init_assigns(game, socket)}
  end
end
