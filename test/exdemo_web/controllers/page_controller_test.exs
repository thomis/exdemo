defmodule ExdemoWeb.PageControllerTest do
  use ExdemoWeb.ConnCase

  test "GET / - without registered user", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 302) =~
             "<html><body>You are being <a href=\"/logon\">redirected</a>.</body></html>"
  end

  test "GET / - with registered user", %{conn: conn} do
    conn =
      conn
      |> Plug.Test.init_test_session(username: "whatever", session_id: "whatever")
      |> get(~p"/")

    assert html_response(conn, 200) =~ "Monitor"
    assert html_response(conn, 200) =~ "whatever"
  end
end
