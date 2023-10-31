defmodule TicWeb.GameLive.FormComponent do
  use TicWeb, :live_component
  alias Tic.Player

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        New Game
        <:subtitle>Choose a game name or accept the suggestion</:subtitle>
      </.header>

      <.simple_form for={@form} id="player-form" phx-target={@myself} phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" required="true" />
        <:actions>
          <.button name="vs" value="AI" phx-disable-with="Starting...">
            Play against AI
          </.button>
          <.button name="vs" value="human" phx-disable-with="Starting...">
            Play with you friend
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(_, socket) do
    suggestion = Ecto.UUID.generate()
    form = to_form(%{"name" => suggestion})

    {:ok, assign(socket, :form, form)}
  end

  @impl true
  @spec handle_event(<<_::32>>, map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("save", %{"name" => game_name}, socket) do
    player1 = %Player{name: name}

    case vs do
      "AI" ->
        player2 = %Player{name: "AI", type: :computer, symbol: :o}
        Tic.new_game(game_name, player1)
        Tic.join(name, player2)

        {:noreply,
         socket
         |> push_navigate(to: ~p"/games/#{name}/play")}

      "human" ->
        {:ok, _, name} = Tic.new_game(name, player1)

        {:noreply,
         socket
         |> push_navigate(to: ~p"/games/#{name}/play")}
    end
  end
end
