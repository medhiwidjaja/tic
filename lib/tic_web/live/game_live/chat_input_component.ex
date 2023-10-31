defmodule TicWeb.GameLive.ChatInputComponent do
  use TicWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} id="chat-form" phx-target={@myself} phx-submit="save">
        <.input field={@form[:message]} type="text" required="true" value={@text_input} />
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    form = to_form(%{"message" => ""})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, form)}
  end

  @impl true
  def handle_event("save", message, socket) do
    game_name = socket.assigns.game_name
    TicWeb.GameChannel.broadcast!("game:" <> game_name, "chat", message)
    {:noreply, assign(socket, :text_input, nil)}
  end
end
