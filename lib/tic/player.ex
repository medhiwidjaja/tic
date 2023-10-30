defmodule Tic.Player do
  @moduledoc """
  Player struct.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          streak: integer(),
          symbol: :x | :o,
          type: :human | :computer,
          id: integer()
        }

  defstruct(
    name: "",
    streak: 0,
    symbol: :x,
    type: :human,
    id: nil
  )

  @doc """
  Increment the player's streak

  ## Examples

    iex> %{streak: streak} = Tic.Player.increment_streak(%Tic.Player{})
    iex> streak
    1
  """
  def increment_streak(player) do
    %__MODULE__{player | streak: player.streak + 1}
  end
end
