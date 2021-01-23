defmodule TsHelperWeb.TradeLiveTest do
  use TsHelperWeb.ConnCase

  import Phoenix.LiveViewTest

  alias TsHelper.Skills

  describe "Index" do
    test "lists all trades", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.trade_index_path(conn, :index))

      assert html =~ "Listing Trades"
    end

    ~W[Sociability Wood Stone Metal Fashioning Flora Fauna Science Other]
    |> Enum.each(fn trade_name ->
      test "has #{trade_name}", %{conn: conn} do
        {:ok, index_live, html} = live(conn, Routes.trade_index_path(conn, :index))
        assert html =~ unquote(trade_name)
        assert render(index_live) =~ unquote(trade_name)
      end
    end)
  end
end
