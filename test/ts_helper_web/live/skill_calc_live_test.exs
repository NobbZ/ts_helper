defmodule TsHelperWeb.SkillCalcLiveTest do
  use TsHelperWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, Routes.skill_calc_path(conn, :index))
    assert disconnected_html =~ "Skill Calculator"
    assert render(page_live) =~ "Skill Calculator"
  end
end
