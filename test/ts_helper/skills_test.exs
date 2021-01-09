defmodule TsHelper.SkillsTest do
  use TsHelper.DataCase

  alias TsHelper.Skills

  describe "trades" do
    alias TsHelper.Skills.Trade

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def trade_fixture(attrs \\ %{}) do
      {:ok, trade} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Skills.create_trade()

      trade
    end

    test "list_trades/0 returns all trades" do
      trade = trade_fixture()
      assert Skills.list_trades() == [trade]
    end

    test "get_trade!/1 returns the trade with given id" do
      trade = trade_fixture()
      assert Skills.get_trade!(trade.id) == trade
    end

    test "create_trade/1 with valid data creates a trade" do
      assert {:ok, %Trade{} = trade} = Skills.create_trade(@valid_attrs)
      assert trade.name == "some name"
    end

    test "create_trade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Skills.create_trade(@invalid_attrs)
    end

    test "update_trade/2 with valid data updates the trade" do
      trade = trade_fixture()
      assert {:ok, %Trade{} = trade} = Skills.update_trade(trade, @update_attrs)
      assert trade.name == "some updated name"
    end

    test "update_trade/2 with invalid data returns error changeset" do
      trade = trade_fixture()
      assert {:error, %Ecto.Changeset{}} = Skills.update_trade(trade, @invalid_attrs)
      assert trade == Skills.get_trade!(trade.id)
    end

    test "delete_trade/1 deletes the trade" do
      trade = trade_fixture()
      assert {:ok, %Trade{}} = Skills.delete_trade(trade)
      assert_raise Ecto.NoResultsError, fn -> Skills.get_trade!(trade.id) end
    end

    test "change_trade/1 returns a trade changeset" do
      trade = trade_fixture()
      assert %Ecto.Changeset{} = Skills.change_trade(trade)
    end
  end
end
