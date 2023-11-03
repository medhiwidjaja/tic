defmodule TicWeb.UserLoginLive do
  use TicWeb, :live_view

  def render(assigns) do
    ~H"""
    <.card class="bg-white mt-20 mx-auto max-w-sm">
      <.header class="text-center">
        Sign in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:name]} label="Name" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </.card>
    """
  end

  def mount(_params, session, socket) do
    name = live_flash(socket.assigns.flash, :name)
    form = to_form(%{"name" => name}, as: "user")
    socket = PhoenixLiveSession.maybe_subscribe(socket, session)
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end

  def handle_info({:live_session_updated, session}, socket) do
    {:noreply,
     socket
     |> assign(:user_return_to, Map.get(session, "user_return_to", []))}
  end
end
