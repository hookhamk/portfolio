defmodule PortfolioWeb.PageController do
  use PortfolioWeb, :controller

  alias Portfolio.Content

  def home(conn, _params) do
    intro = Content.page("home") || %{title: Portfolio.site().name, body: ""}

    render(conn, :home,
      intro: intro,
      featured: Content.featured_projects(),
      recent: Content.entries(limit: 5),
      meta_description: intro[:tagline]
    )
  end

  def colophon(conn, _params) do
    page = Content.page("colophon") || %{title: "About this site", body: ""}

    render(conn, :colophon,
      page: page,
      page_title: page.title,
      runtime: Portfolio.runtime(),
      counts: %{projects: length(Content.projects()), entries: length(Content.entries())},
      meta_description: "How this site is built and where it runs."
    )
  end
end
