defmodule TicWeb.GameLive.FormComponent do
  use TicWeb, :live_component
  alias Tic.Player

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Hello, <%= @current_user.name %>! Let's create a game!
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
  @spec update(any(), %{
          :assigns => atom() | %{:current_user => any(), optional(any()) => any()},
          optional(any()) => any()
        }) :: {:ok, map()}
  def update(assigns, socket) do
    suggestion = Ecto.UUID.generate()
    form = to_form(%{"name" => suggestion, "vs" => nil})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, form)}
  end

  @impl true
  @spec handle_event(<<_::32>>, map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("save", %{"name" => game_name, "vs" => vs}, socket) do
    current_user = socket.assigns.current_user
    player1 = %Player{name: current_user.name}

    case vs do
      "AI" ->
        player2 = %Player{name: "AI", type: :computer, symbol: :o}
        Tic.new_game(game_name, player1)
        Tic.join(game_name, player2)

        {:noreply,
         socket
         |> push_navigate(to: ~p"/games/#{game_name}/play")}

      "human" ->
        {:ok, _, game_name} = Tic.new_game(game_name, player1)

        {:noreply,
         socket
         |> push_navigate(to: ~p"/games/#{game_name}/play")}
    end
  end
end
