defmodule Tic.GameSupervisor do
  @moduledoc """
  The Game Supervisor, a dynamic supervisor providing fault tolerance
  """
  alias Tic.GameServer

  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_game(game_name, player) do
    child_spec = %{
      id: Game,
      start: {GameServer, :start_link, [game_name, player]},
      restart: :temporary
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def active_games() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, pid, _, _} ->
      Registry.keys(Tic.GameRegistry, pid)
    end)
    |> List.flatten()
  end
end
