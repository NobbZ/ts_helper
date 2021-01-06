defmodule TsHelperWeb.CharLiveTest do
  use TsHelperWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, Routes.chars_path(conn, :index))
    assert disconnected_html =~ "Character List"
    assert render(page_live) =~ "Character List"
  end

  describe "overview" do
    setup :create_char
    setup :connect

    test "char is listed (connected)", %{char: char, connected: page} do
      assert render(page) =~ char.name
    end

    test "char is listed (disconnected)", %{char: char, disconnected: page} do
      assert page =~ char.name
    end

    test "char has delete buton", %{char: char, connected: page} do
      assert page |> has_element?("tr.char button.delete#delete-#{char.id}")
    end

    test "char can be deleted", %{char: char, connected: page} do
      refute page |> element("tr.char button#delete-#{char.id}") |> render_click() =~ char.name
    end
  end

  defp create_char(_ctx) do
    {:ok, char} =
      TsHelper.Avatars.create_char(%{
        name: "ExampleChar"
      })

    {:ok, %{char: char}}
  end

  defp connect(%{conn: conn}) do
    {:ok, page_live, disconnected_html} = live(conn, Routes.chars_path(conn, :index))

    {:ok,
     %{
       disconnected: disconnected_html,
       connected: page_live
     }}
  end
end
