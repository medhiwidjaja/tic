defmodule TicWeb.Router do
  use TicWeb, :router
  import TicWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TicWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TicWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/games", GameLive.Index, :index
    live "/games/new", GameLive.Index, :new

    live "/games/:id", GameLive.Show, :show
    # live "/games/:id/send", GameLive.Show, :send
    # live "/games/:id/challenge", GameLive.Show, :challenge
    live "/games/:id/play", GameLive.Play, :play

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TicWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live("/users/register", UserRegistrationLive, :new)
      live("/users/log_in", UserLoginLive, :new)
    end

    post("/users/log_in", UserSessionController, :create)
  end

  scope "/", TicWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)
  end

  # Other scopes may use custom stacks.
  # scope "/api", TicWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:tic, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TicWeb.Telemetry
    end
  end
end
