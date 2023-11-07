defmodule TicWeb.GameComponents do
  @moduledoc """
  Provides site's UI components.
  """
  use Phoenix.Component
  use TicWeb, :verified_routes

  alias Phoenix.LiveView.JS

  attr :board, :map
  attr :player_symbol, :string
  attr :disable, :boolean, default: false
  attr :strike, :list, default: []

  def game_board(assigns) do
    ~H"""
    <div class="w-[310px] h-[310px] mx-auto bg-zinc-300 grid grid-cols-3 gap-2 place-content-center">
      <%= for i <- 1..9 do %>
        <.cell
          symbol={@board.cells[i]}
          cell={i}
          player={@player_symbol}
          disable={@disable}
          highlight={Enum.member?(@strike, i)}
        />
      <% end %>
    </div>
    """
  end

  attr :symbol, :string
  attr :cell, :integer
  attr :player, :string
  attr :disable, :boolean
  attr :highlight, :boolean, default: false
  attr :class, :string, default: nil

  def cell(assigns) do
    ~H"""
    <div
      class={[
        "h-[100px] w-[100px] flex items-center justify-center border-indigo-500",
        if(@highlight, do: "bg-blue-300", else: "bg-white")
      ]}
      phx-click={!@disable && "make-move"}
      phx-value-player={@player}
      phx-value-cell={@cell}
    >
      <.xo symbol={@symbol} />
    </div>
    """
  end

  defp xo(assigns) do
    case assigns.symbol do
      :x -> ~H(<img src={~p"/images/x-thin-svgrepo-com.svg"} />)
      :o -> ~H(<img src={~p"/images/circle-thin-svgrepo-com.svg"} />)
      _ -> ~H()
    end
  end

  attr :game, :map

  def game_message(assigns) do
    ~H"""
    <div class={[
      "w-[320px] h-min-100 mx-auto my-2 p-2 text-zinc-500",
      @game.status == :in_progress && "bg-blue-300",
      @game.status == :won && "bg-green-300",
      @game.status == :tie && "bg-yellow-300",
      @game.status == :init && "bg-zinc-300"
    ]}>
      <div class="w-full h-100 text-center">
        <%= message(@game.status, @game) %>
      </div>
    </div>
    """
  end

  attr :games, :list

  def running_games(assigns) do
    ~H"""
    <div>
      <ul class="list-disc">
        <li :for={game <- @games} id={game.name} class="rounded-lg hover:bg-zinc-600 p-1">
          <.link navigate={~p"/games/#{game.name}"}>
            <%= game.name %> ( <%= game.x && game.x.name %> vs <%= game.o && game.o.name %> )
          </.link>
        </li>
      </ul>
    </div>
    """
  end

  defp message(:won, %{winner: winner} = _game) do
    "#{winner.name} won!"
  end

  defp message(:init, _game), do: "Let's play a game!"
  defp message(:tie, _game), do: "It's a tie"
  defp message(:ready, _game), do: "Click start to begin"
  defp message(:accepted, game), do: "#{game.o.name} accepted the challenge"
  defp message(_, game), do: "#{Tic.Game.get_next_player(game).name} plays next"

  attr :class, :string, default: nil

  @spec x_mark(map()) :: Phoenix.LiveView.Rendered.t()
  def x_mark(assigns), do: ~H(<img src={~p"/images/x-thin-svgrepo-com.svg"} class={@class} />)

  def o_mark(assigns),
    do: ~H(<img src={~p"/images/circle-thin-svgrepo-com.svg"} class={@class} />)

  attr :direction, :string
  slot :inner_block, required: true

  def bouncing(assigns) do
    ~H"""
    <div class={"px-10 font-bold text-xl text-zinc-900 animate-bounce-#{@direction}"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
