defmodule Tic.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :hashed_password, :string
      add :streak, :integer
      add :best_streak, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:name])
  end
end
