defmodule Portfolio.Content.Entry do
  @moduledoc """
  A dated log entry: a change, a milestone, or a lesson learned. One file per
  entry in `priv/content/log/YYYY-MM-DD-<slug>.md`. Entries can point at a
  project, which is how a project page builds its history.
  """

  import Portfolio.Content.Parser, only: [fetch!: 3, one_of!: 4]

  @kinds [:change, :milestone, :lesson]

  @enforce_keys [:slug, :date, :title, :kind, :body]
  defstruct [:slug, :date, :title, :kind, :project, :summary, :body, draft: false]

  def kinds, do: @kinds

  def parse!(path) do
    {attrs, body} = Portfolio.Content.Parser.parse!(path)
    slug = Path.basename(path, ".md")

    %__MODULE__{
      slug: slug,
      date: date!(slug, path),
      title: fetch!(attrs, :title, path),
      kind: attrs |> fetch!(:kind, path) |> one_of!(@kinds, :kind, path),
      project: attrs[:project],
      summary: attrs[:summary],
      draft: Map.get(attrs, :draft, false),
      body: body
    }
  end

  defp date!(<<iso::binary-size(10), "-", _rest::binary>>, path) do
    case Date.from_iso8601(iso) do
      {:ok, date} -> date
      {:error, _} -> raise ArgumentError, "#{path}: filename must start with YYYY-MM-DD-"
    end
  end

  defp date!(_slug, path),
    do: raise(ArgumentError, "#{path}: filename must start with YYYY-MM-DD-")
end
