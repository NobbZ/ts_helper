defmodule TsHelper.AvatarsTest do
  use TsHelper.DataCase

  alias TsHelper.Avatars

  describe "chars" do
    alias TsHelper.Avatars.Char

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def char_fixture(attrs \\ %{}) do
      {:ok, char} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Avatars.create_char()

      char
    end

    test "list_chars/0 returns all chars" do
      char = char_fixture()
      assert Avatars.list_chars() == [char]
    end

    test "get_char!/1 returns the char with given id" do
      char = char_fixture()
      assert Avatars.get_char!(char.id) == char
    end

    test "create_char/1 with valid data creates a char" do
      assert {:ok, %Char{} = char} = Avatars.create_char(@valid_attrs)
      assert char.name == "some name"
    end

    test "create_char/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Avatars.create_char(@invalid_attrs)
    end

    test "update_char/2 with valid data updates the char" do
      char = char_fixture()
      assert {:ok, %Char{} = char} = Avatars.update_char(char, @update_attrs)
      assert char.name == "some updated name"
    end

    test "update_char/2 with invalid data returns error changeset" do
      char = char_fixture()
      assert {:error, %Ecto.Changeset{}} = Avatars.update_char(char, @invalid_attrs)
      assert char == Avatars.get_char!(char.id)
    end

    test "delete_char/1 deletes the char" do
      char = char_fixture()
      assert {:ok, %Char{}} = Avatars.delete_char(char)
      assert_raise Ecto.NoResultsError, fn -> Avatars.get_char!(char.id) end
    end

    test "change_char/1 returns a char changeset" do
      char = char_fixture()
      assert %Ecto.Changeset{} = Avatars.change_char(char)
    end
  end
end
