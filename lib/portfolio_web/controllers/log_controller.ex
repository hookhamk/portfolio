defmodule PortfolioWeb.LogController do
  use PortfolioWeb, :controller

  alias Portfolio.Content
  alias Portfolio.Content.Entry

  @kinds Map.new(Entry.kinds(), &{Atom.to_string(&1), &1})

  def index(conn, params) do
    kind = @kinds[params["kind"]]

    render(conn, :index,
      entries: Content.entries(kind: kind),
      kind: kind,
      page_title: "Log",
      meta_description: "Changes, milestones and lessons learned, as they happen."
    )
  end

  def show(conn, %{"slug" => slug}) do
    entry = Content.get_entry!(slug)
    project = entry.project && Content.get_project!(entry.project)

    render(conn, :show,
      entry: entry,
      project: project,
      page_title: entry.title,
      meta_description: entry.summary,
      og_type: "article"
    )
  end
end
