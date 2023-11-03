defmodule TicWeb.UserLiveAuth do
  import Phoenix.Component
  import Phoenix.LiveView

  alias Tic.Users

  def on_mount(:default, params, session, socket) do
    with %{"user_token" => user_token} <- session do
      socket =
        assign_new(socket, :current_user, fn ->
          Users.get_user_by_session_token(user_token)
        end)

      {:cont, socket}
    else
      _ ->
        with %{"id" => id} <- params,
             %{live_action: :play} <- socket.assigns do
          Tic.ETS.insert_game_path(id)
          {:halt, push_navigate(socket, to: "/users/log_in?game=#{id}")}
        else
          _ ->
            {:halt, push_navigate(socket, to: "/users/log_in")}
        end
    end
  end
end
