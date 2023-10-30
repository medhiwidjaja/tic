defmodule Tic.Repo do
  use Ecto.Repo,
    otp_app: :tic,
    adapter: Ecto.Adapters.Postgres
end
