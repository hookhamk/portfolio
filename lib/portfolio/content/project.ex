defmodule Portfolio.Content.Project do
  @moduledoc """
  A piece of work: a website, a system, a tool. One file per project in
  `priv/content/projects/<slug>.md`.
  """

  import Portfolio.Content.Parser, only: [fetch!: 3, one_of!: 4]

  @kinds [:website, :infrastructure, :tool, :other]
  @statuses [:live, :in_progress, :paused, :retired, :private]

  @enforce_keys [:slug, :title, :kind, :summary, :body]
  defstruct [
    :slug,
    :title,
    :kind,
    :summary,
    :role,
    :status,
    :started,
    :ended,
    :body,
    stack: [],
    links: [],
    featured: false,
    draft: false
  ]

  def kinds, do: @kinds

  def parse!(path) do
    {attrs, body} = Portfolio.Content.Parser.parse!(path)

    %__MODULE__{
      slug: Path.basename(path, ".md"),
      title: fetch!(attrs, :title, path),
      kind: attrs |> fetch!(:kind, path) |> one_of!(@kinds, :kind, path),
      summary: fetch!(attrs, :summary, path),
      role: attrs[:role],
      status: attrs |> Map.get(:status, :live) |> one_of!(@statuses, :status, path),
      started: attrs[:started],
      ended: attrs[:ended],
      stack: Map.get(attrs, :stack, []),
      links: attrs |> Map.get(:links, []) |> Enum.map(&link!(&1, path)),
      featured: Map.get(attrs, :featured, false),
      draft: Map.get(attrs, :draft, false),
      body: body
    }
  end

  defp link!({label, url}, _path) when is_binary(label) and is_binary(url),
    do: %{label: label, url: url}

  defp link!(other, path),
    do:
      raise(
        ArgumentError,
        ~s|#{path}: links must be {"Label", "https://..."}, got: #{inspect(other)}|
      )
end
