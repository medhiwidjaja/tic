defmodule TicWeb.GameLive.Show do
  use TicWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    game_name = params["id"]

    if Enum.member?(Tic.active_games(), game_name) do
      game_state = Tic.get_state(game_name)
      logged_in? = Map.has_key?(socket.assigns, :current_user)
      current_user = logged_in? && socket.assigns.current_user
      TicWeb.GameChannel.subscribe("game:#{game_name}")

      {:ok,
       socket
       |> assign(:current_user, current_user)
       |> assign(:game_name, game_name)
       |> assign(:next, game_state.next)
       |> assign(:active_games, Tic.active_games())
       |> assign(:game, game_state)}
    else
      {:ok,
       socket
       |> put_flash(:error, "Game couldn't be found")
       |> push_navigate(to: ~p"/games")}
    end
  end

  # Callbacks

  @doc """
  Info event handler to update the game based on message from every move
  """
  @impl true
  def handle_info(%{event: "update", payload: %{game: game, game_status: game_status}}, socket) do
    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:game_status, game_status)}
  end

  defdelegate disable_move?(game, player), to: Tic.Game
end
