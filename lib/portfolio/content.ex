defmodule Portfolio.Content do
  @moduledoc """
  All site content, read from `priv/content` at compile time.

  Adding, editing or deleting a file recompiles this module. Drafts
  (`draft: true`) are shown only when `:show_drafts` is set, which is on in dev.
  """

  alias Portfolio.Content.{Entry, Parser, Project}

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  @root Path.expand("../../priv/content", __DIR__)

  # Files starting with "_" are templates and are skipped.
  content_files = fn dir ->
    @root
    |> Path.join(dir <> "/*.md")
    |> Path.wildcard()
    |> Enum.reject(&String.starts_with?(Path.basename(&1), "_"))
  end

  @project_paths content_files.("projects")
  @entry_paths content_files.("log")
  @page_paths content_files.("pages")
  @all_paths @project_paths ++ @entry_paths ++ @page_paths

  for path <- @all_paths, do: @external_resource(path)

  @paths_hash :erlang.md5(@all_paths)

  @projects Enum.map(@project_paths, &Project.parse!/1)
  @entries Enum.map(@entry_paths, &Entry.parse!/1)
  @pages Map.new(@page_paths, fn path ->
           {attrs, body} = Parser.parse!(path)
           {Path.basename(path, ".md"), Map.put(attrs, :body, body)}
         end)

  project_slugs = MapSet.new(@projects, & &1.slug)

  for %Entry{project: slug} = entry <- @entries,
      slug != nil and not MapSet.member?(project_slugs, slug) do
    raise ArgumentError,
          "log/#{entry.slug}.md: project #{inspect(slug)} has no file in priv/content/projects"
  end

  @doc false
  # Recompile when files are added or removed, not only when they change.
  def __mix_recompile__? do
    ~w(projects log pages)
    |> Enum.flat_map(&Path.wildcard(Path.join(@root, &1 <> "/*.md")))
    |> Enum.reject(&String.starts_with?(Path.basename(&1), "_"))
    |> :erlang.md5() != @paths_hash
  end

  @doc "Visible projects, featured first, then most recently started."
  def projects do
    @projects
    |> Enum.filter(&visible?/1)
    |> Enum.sort_by(&(&1.started || ""), :desc)
    |> Enum.sort_by(&(!&1.featured))
  end

  def featured_projects, do: Enum.filter(projects(), & &1.featured)

  @doc "Visible projects grouped by kind, in `Project.kinds/0` order, empty kinds dropped."
  def projects_by_kind do
    grouped = Enum.group_by(projects(), & &1.kind)

    for kind <- Project.kinds(), Map.has_key?(grouped, kind), do: {kind, grouped[kind]}
  end

  def get_project!(slug) do
    Enum.find(projects(), &(&1.slug == slug)) ||
      raise NotFoundError, "no project #{inspect(slug)}"
  end

  @doc "Visible log entries, newest first. Options: `:kind`, `:project`, `:limit`."
  def entries(opts \\ []) do
    project_visible = MapSet.new(projects(), & &1.slug)

    @entries
    |> Enum.filter(&visible?/1)
    |> Enum.filter(&(&1.project == nil or MapSet.member?(project_visible, &1.project)))
    |> filter_by(:kind, opts[:kind])
    |> filter_by(:project, opts[:project])
    |> Enum.sort_by(& &1.date, {:desc, Date})
    |> then(&if opts[:limit], do: Enum.take(&1, opts[:limit]), else: &1)
  end

  def get_entry!(slug) do
    Enum.find(entries(), &(&1.slug == slug)) ||
      raise NotFoundError, "no log entry #{inspect(slug)}"
  end

  @doc "A standalone page from `priv/content/pages`, or nil."
  def page(name) do
    case @pages[name] do
      %{draft: true} = page -> if show_drafts?(), do: page
      page -> page
    end
  end

  def show_drafts?, do: Application.get_env(:portfolio, :show_drafts, false)

  defp visible?(%{draft: draft}), do: !draft or show_drafts?()

  defp filter_by(items, _field, nil), do: items
  defp filter_by(items, field, value), do: Enum.filter(items, &(Map.get(&1, field) == value))
end
