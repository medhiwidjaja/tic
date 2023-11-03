defmodule TicWeb.GameLive.Index do
  use TicWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    logged_in? = Map.has_key?(session, "user_token")
    current_user = logged_in? && Tic.Users.get_user_by_session_token(session["user_token"])

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:active_games, Tic.active_games() |> Enum.map(&Tic.GameServer.status/1))
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
end
