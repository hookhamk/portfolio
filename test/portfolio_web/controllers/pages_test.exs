defmodule PortfolioWeb.PagesTest do
  # Toggles application env, so not async.
  use PortfolioWeb.ConnCase, async: false

  alias Portfolio.Content

  setup do
    previous = Application.get_env(:portfolio, :show_drafts)
    Application.put_env(:portfolio, :show_drafts, true)
    on_exit(fn -> Application.put_env(:portfolio, :show_drafts, previous) end)
  end

  test "health check", %{conn: conn} do
    assert conn |> get(~p"/healthz") |> text_response(200) == "ok"
  end

  test "top-level pages render", %{conn: conn} do
    for path <- [~p"/", ~p"/work", ~p"/log", ~p"/log?kind=lesson", ~p"/colophon"] do
      assert html_response(get(conn, path), 200) =~ Portfolio.site().name
    end
  end

  test "every project and entry page renders", %{conn: conn} do
    for project <- Content.projects() do
      assert html_response(get(conn, ~p"/work/#{project.slug}"), 200) =~ project.title
    end

    for entry <- Content.entries() do
      assert html_response(get(conn, ~p"/log/#{entry.slug}"), 200) =~ entry.title
    end
  end

  test "drafts are not reachable when drafts are hidden", %{conn: conn} do
    drafts = Enum.filter(Content.projects(), & &1.draft)
    Application.put_env(:portfolio, :show_drafts, false)

    for project <- drafts do
      assert_error_sent 404, fn -> get(conn, ~p"/work/#{project.slug}") end
    end
  end

  test "unknown pages are 404", %{conn: conn} do
    assert_error_sent 404, fn -> get(conn, ~p"/work/does-not-exist") end
    assert_error_sent 404, fn -> get(conn, ~p"/log/does-not-exist") end
  end
end
