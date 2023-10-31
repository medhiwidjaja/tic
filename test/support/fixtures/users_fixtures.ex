defmodule Tic.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tic.Users` context.
  """

  def unique_user_name, do: "user_name#{System.unique_integer()}"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: unique_user_name(),
      password: valid_user_password()
    })
  end

  @spec user_fixture(any()) :: any()
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Tic.Users.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_name} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_name.text_body, "[TOKEN]")
    token
  end
end
