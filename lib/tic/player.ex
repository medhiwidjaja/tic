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
end
