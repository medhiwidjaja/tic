defmodule TicWeb.UserLiveAuth do
  import Phoenix.Component
  import Phoenix.LiveView

  alias Tic.Users

  def on_mount(:default, _params, session, socket) do
    with %{"user_token" => user_token} <- session do
      socket =
        assign_new(socket, :current_user, fn ->
          Users.get_user_by_session_token(user_token)
        end)

      {:cont, socket}

      if socket.assigns.current_user do
        {:cont, socket}
      else
        {:halt, push_navigate(socket, to: "/users/log_in")}
      end
    else
      _ ->
        {:cont, socket}
    end
  end
end
