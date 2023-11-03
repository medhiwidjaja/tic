defmodule TicWeb.ChatLive do
  use TicWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full px-5 flex flex-col justify-between">
      <div id="messages" role="log" aria-live="polite" class="flex flex-col mt-5">
        <div class="flex justify-start mb-4">
          <div class="ml-2 py-3 px-4 bg-gray-400 rounded-br-lg rounded-tr-lg rounded-tl-xl text-white">
            Type your comments!
          </div>
        </div>
        <%= for message <- @messages do %>
          <div class="flex justify-start mb-1">
            <div>
              <div class="text-zinc-500 ml-2 font-bold text-xs"><%= message["from"] %></div>
              <div class="ml-2 px-2 bg-gray-400 rounded-br-lg rounded-tr-lg rounded-tl-xl text-white">
                <%= message["body"] %>
              </div>
            </div>
          </div>
        <% end %>
      </div>
      <div class="py-5">
        <.live_component
          id="ChatName"
          module={TicWeb.GameLive.ChatInputComponent}
          name={@name}
          text_input={@text_input}
          game_name={@game_name}
        />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    # logged_in? = Map.has_key?(socket.assigns, :current_user)
    game_name = session["game_name"]
    name = session["name"]
    TicWeb.GameChannel.subscribe("chat:#{game_name}")
    # name = logged_in? && socket.assigns.current_user.name

    {:ok,
     socket
     |> assign(:game_name, game_name)
     |> assign(:name, name || "Anonymous")
     |> assign(:messages, [])
     |> assign(:text_input, "")}
  end

  # Callbacks

  @impl true
  def handle_info(
        %{event: "chat", payload: %{"body" => _body, "from" => _from} = message},
        socket
      ) do
    messages = socket.assigns.messages ++ [message]

    {:noreply,
     socket
     |> assign(:messages, messages)}
  end
end
