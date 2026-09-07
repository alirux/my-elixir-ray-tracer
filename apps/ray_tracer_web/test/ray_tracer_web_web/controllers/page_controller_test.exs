defmodule RayTracerWebWeb.PageControllerTest do
  use RayTracerWebWeb.ConnCase, async: true

  test "GET /privacy renders the policy", %{conn: conn} do
    conn = get(conn, ~p"/privacy")
    body = html_response(conn, 200)

    assert body =~ "Privacy Policy"
    assert body =~ "GoatCounter"
    assert body =~ "privacy@codingful.com"
  end

  test "the layout loads the GoatCounter script", %{conn: conn} do
    body = conn |> get(~p"/privacy") |> html_response(200)

    assert body =~ ~s(data-goatcounter="https://lirux-mrt.goatcounter.com/count")
    assert body =~ "https://gc.zgo.at/count.js"
  end

  test "the CSP allows the GoatCounter script and its beacon", %{conn: conn} do
    conn = get(conn, ~p"/privacy")
    [csp] = Plug.Conn.get_resp_header(conn, "content-security-policy")

    assert csp =~ "script-src 'self' https://gc.zgo.at"
    assert csp =~ "img-src 'self' data: https://lirux-mrt.goatcounter.com"
    assert csp =~ "connect-src 'self' ws: wss: https://lirux-mrt.goatcounter.com"
  end
end
