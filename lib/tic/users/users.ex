defmodule Tic.Users do
  alias Tic.Repo
  alias Tic.User
  alias Tic.UserToken

  @doc """
  Gets a user by name.

  ## Examples

      iex> get_user_by_name("ninjaEx")
      %User{}

      iex> get_user_by_name("ninjaEx")
      nil

  """
  def get_user_by_name(name) when is_binary(name) do
    Repo.get_by(User, name: name)
  end

  @doc """
  Gets a user by name and password.

  ## Examples

      iex> get_user_by_name_and_password("ninjaEx", "correct_password")
      %User{}

      iex> get_user_by_name_and_password("ninjaEx", "invalid_password")
      nil

  """
  def get_user_by_name_and_password(name, password)
      when is_binary(name) and is_binary(password) do
    user = Repo.get_by(User, name: name)
    if User.valid_password?(user, password), do: user
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end
end
