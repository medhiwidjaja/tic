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

      if socket.assigns.current_user do
        {:cont, assign(socket, :tellme, "It's there")}
      else
        {:halt, redirect(socket, to: "/login")}
      end
    else
      _ ->
        {:halt,
         socket
         |> put_flash(:error, "You are not allowed. Sorry")
         |> push_navigate(to: "/games")}
    end
  end
end
