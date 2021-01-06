defmodule TsHelperWeb.CharLiveTest do
  use TsHelperWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, Routes.chars_path(conn, :index))
    assert disconnected_html =~ "Character List"
    assert render(page_live) =~ "Character List"
  end
end
