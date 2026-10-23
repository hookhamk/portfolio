defmodule PortfolioWeb.WorkController do
  use PortfolioWeb, :controller

  alias Portfolio.Content

  def index(conn, _params) do
    render(conn, :index,
      groups: Content.projects_by_kind(),
      page_title: "Work",
      meta_description: "Websites, systems and tools I've built and run."
    )
  end

  def show(conn, %{"slug" => slug}) do
    project = Content.get_project!(slug)

    render(conn, :show,
      project: project,
      history: Content.entries(project: project.slug),
      page_title: project.title,
      meta_description: project.summary,
      og_type: "article"
    )
  end
end
