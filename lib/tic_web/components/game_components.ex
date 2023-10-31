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
    <div class="w-[300px] h-[300px] mx-auto bg-zinc-300 grid grid-cols-3 gap-2 place-content-center">
      <%= for i <- 1..9 do %>
        <.cell
          symbol={@board.cells[i]}
          cell={i}
          player={@player_symbol}
          disable={@disable}
          class={Enum.member?(@strike, i) && "bg-blue-300"}
        />
      <% end %>
    </div>
    """
  end

  attr :symbol, :string
  attr :cell, :integer
  attr :player, :string
  attr :disable, :boolean
  attr :class, :string, default: nil

  def cell(assigns) do
    ~H"""
    <div
      class={[
        "h-[100px] flex bg-white items-center justify-center border-indigo-500",
        @class
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

  defp message(:won, winner, _turn) do
    "#{winner.name} won!"
  end

  defp message(:init, _, _), do: "Let's play a game!"
  defp message(:tie, _, _), do: "It's a tie"
  defp message(_, _, next), do: "#{next} plays next"
end
