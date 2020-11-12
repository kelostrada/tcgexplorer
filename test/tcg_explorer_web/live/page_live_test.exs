defmodule TcgExplorerWeb.PageLiveTest do
  use TcgExplorerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to TCG Explorer!"
    assert render(page_live) =~ "Welcome to TCG Explorer!"
  end
end
