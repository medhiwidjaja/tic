defmodule Tic.ETS do
  @table_name :tic_session

  @spec new() :: atom() | :ets.tid()
  def new do
    :ets.new(@table_name, [:set, :public, :named_table])
  end

  def insert_game_path(game_id) do
    :ets.insert(@table_name, {game_id, %{path: "/games/#{game_id}/play"}})
  end

  def get_game_path(game_id) do
    [{_, %{path: path}}] = :ets.lookup(@table_name, game_id)
    path
  end

  def delete(key) do
    :ets.delete(@table_name, key)
  end
end
