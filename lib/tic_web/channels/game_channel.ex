defmodule TicWeb.GameChannel do
  @channel_prefix "game:"

  def broadcast!(name, payload, assigns) do
    TicWeb.Endpoint.broadcast!(@channel_prefix <> name, payload, assigns)
  end

  def subscribe(name) do
    Phoenix.PubSub.subscribe(Tic.PubSub, @channel_prefix <> name)
  end
end
