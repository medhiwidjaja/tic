defmodule TicWeb.GameComponents do
  @moduledoc """
  Provides site's UI components.
  """
  use Phoenix.Component
  use TicWeb, :verified_routes

  # alias Phoenix.LiveView.JS

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
        <%= message(@game.status, @game.winner, @game.next) %>
      </div>
    </div>
    """
  end

  attr :games, :list

  def running_games(assigns) do
    ~H"""
    <div>
      <ul>
        <li :for={game <- @games} id={game.name}>
          <.link navigate={~p"/games/#{game.name}"} class="h-10 border-top border-zinc-200">
            <%= game.name %> ( <%= game.x && game.x.name %> vs <%= game.o && game.o.name %> )
          </.link>
        </li>
      </ul>
    </div>
    """
  end

  defp message(:won, winner, _turn) do
    "#{winner.name} won!"
  end

  defp message(:init, _, _), do: "Let's play a game!"
  defp message(:tie, _, _), do: "It's a tie"
  defp message(_, _, next), do: "#{next} plays next"

  attr :class, :string, default: nil

  def x_mark(assigns), do: ~H(<img src={~p"/images/x-thin-svgrepo-com.svg"} class={@class} />)

  def o_mark(assigns),
    do: ~H(<img src={~p"/images/circle-thin-svgrepo-com.svg"} class={@class} />)
end
