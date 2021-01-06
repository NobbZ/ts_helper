defmodule TsHelper.Avatars do
  @moduledoc """
  The Avatars context.
  """

  import Ecto.Query, warn: false
  alias TsHelper.Repo

  alias TsHelper.Avatars.Char

  @doc """
  Returns the list of chars.

  ## Examples

      iex> list_chars()
      [%Char{}, ...]

  """
  def list_chars do
    Repo.all(Char)
  end

  @doc """
  Gets a single char.

  Raises `Ecto.NoResultsError` if the Char does not exist.

  ## Examples

      iex> get_char!(123)
      %Char{}

      iex> get_char!(456)
      ** (Ecto.NoResultsError)

  """
  def get_char!(id), do: Repo.get!(Char, id)

  @doc """
  Creates a char.

  ## Examples

      iex> create_char(%{field: value})
      {:ok, %Char{}}

      iex> create_char(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_char(attrs \\ %{}) do
    %Char{}
    |> Char.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a char.

  ## Examples

      iex> update_char(char, %{field: new_value})
      {:ok, %Char{}}

      iex> update_char(char, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_char(%Char{} = char, attrs) do
    char
    |> Char.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a char.

  ## Examples

      iex> delete_char(char)
      {:ok, %Char{}}

      iex> delete_char(char)
      {:error, %Ecto.Changeset{}}

  """
  def delete_char(%Char{} = char) do
    Repo.delete(char)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking char changes.

  ## Examples

      iex> change_char(char)
      %Ecto.Changeset{data: %Char{}}

  """
  def change_char(%Char{} = char, attrs \\ %{}) do
    Char.changeset(char, attrs)
  end
end
