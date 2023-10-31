defmodule TicWeb.GameLive.Index do
  use TicWeb, :live_view
  # import Tic.GameComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
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