defmodule PortfolioWeb.ContentComponents do
  @moduledoc """
  Building blocks for project and log pages.
  """
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: PortfolioWeb.Endpoint, router: PortfolioWeb.Router

  alias Portfolio.Content.{Entry, Project}

  @kind_labels %{
    website: "Websites",
    infrastructure: "Infrastructure",
    tool: "Tools",
    other: "Other",
    change: "Change",
    milestone: "Milestone",
    lesson: "Lesson learned"
  }

  @status_labels %{
    live: "Live",
    in_progress: "In progress",
    paused: "Paused",
    retired: "Retired",
    private: "Private"
  }

  def kind_label(kind), do: Map.fetch!(@kind_labels, kind)
  def status_label(status), do: Map.fetch!(@status_labels, status)

  def format_date(%Date{} = date), do: Calendar.strftime(date, "%b %-d, %Y")

  @doc "Renders compiled Markdown. The parser escapes raw HTML, so this is safe."
  attr :html, :string, required: true
  attr :class, :string, default: nil

  def markdown(assigns) do
    ~H"""
    <div class={["prose", @class]}>{Phoenix.HTML.raw(@html)}</div>
    """
  end

  attr :item, :map, required: true

  def draft_badge(assigns) do
    ~H"""
    <span :if={@item.draft} class="badge badge-warning badge-sm">Draft</span>
    """
  end

  attr :project, Project, required: true

  def project_card(assigns) do
    ~H"""
    <.link
      navigate={~p"/work/#{@project.slug}"}
      class="card bg-base-200 hover:bg-base-300 transition-colors"
    >
      <div class="card-body gap-2">
        <div class="flex items-center gap-2">
          <h3 class="card-title text-lg">{@project.title}</h3>
          <.draft_badge item={@project} />
        </div>
        <p class="text-base-content/80">{@project.summary}</p>
        <.stack_list :if={@project.stack != []} stack={@project.stack} />
      </div>
    </.link>
    """
  end

  attr :stack, :list, required: true

  def stack_list(assigns) do
    ~H"""
    <ul class="flex flex-wrap gap-1.5" aria-label="Built with">
      <li :for={tech <- @stack} class="badge badge-ghost badge-sm">{tech}</li>
    </ul>
    """
  end

  attr :entries, :list, required: true

  def entry_list(assigns) do
    ~H"""
    <ol class="border-l-2 border-base-300 ml-1.5 space-y-6">
      <li :for={entry <- @entries} class="relative pl-6">
        <span class={[
          "absolute -left-[7px] top-1.5 size-3 rounded-full",
          entry_dot(entry)
        ]} />
        <div class="flex flex-wrap items-baseline gap-x-3 gap-y-1 text-sm text-base-content/70">
          <time datetime={Date.to_iso8601(entry.date)}>{format_date(entry.date)}</time>
          <span>{kind_label(entry.kind)}</span>
          <.draft_badge item={entry} />
        </div>
        <.link navigate={~p"/log/#{entry.slug}"} class="font-semibold hover:underline">
          {entry.title}
        </.link>
        <p :if={entry.summary} class="text-base-content/80">{entry.summary}</p>
      </li>
    </ol>
    """
  end

  defp entry_dot(%Entry{kind: :milestone}), do: "bg-primary"
  defp entry_dot(%Entry{kind: :lesson}), do: "bg-accent"
  defp entry_dot(%Entry{}), do: "bg-base-content/40"
end
