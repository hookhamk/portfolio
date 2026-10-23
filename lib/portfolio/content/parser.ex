defmodule Portfolio.Content.Parser do
  @moduledoc """
  Parses a content file: an Elixir map of attributes, a `---` line, then Markdown.

      %{
        title: "Haunted 365",
        kind: :website
      }
      ---
      Markdown body...

  Runs at compile time, so a malformed file fails the build instead of a request.
  """

  @markdown_opts [
    extension: [
      table: true,
      strikethrough: true,
      autolink: true,
      tasklist: true,
      header_id_prefix: ""
    ],
    render: [unsafe: false]
  ]

  @doc "Returns `{attrs_map, body_html}` for the file at `path`."
  def parse!(path) do
    case path |> File.read!() |> String.split(~r/\r?\n---\r?\n/, parts: 2) do
      [front, body] ->
        {attrs, _binding} = Code.eval_string(front, [], file: path)

        unless is_map(attrs) do
          raise ArgumentError, "#{path}: attributes must be a map, got: #{inspect(attrs)}"
        end

        {attrs, MDEx.to_html!(body, @markdown_opts)}

      [_] ->
        raise ArgumentError, "#{path}: missing `---` line between attributes and body"
    end
  end

  @doc "Raises unless `value` is one of `allowed`; returns `value`."
  def one_of!(value, allowed, field, path) do
    if value in allowed do
      value
    else
      raise ArgumentError,
            "#{path}: #{field} must be one of #{inspect(allowed)}, got: #{inspect(value)}"
    end
  end

  @doc "Fetches a required attribute or raises with the file path."
  def fetch!(attrs, key, path) do
    case Map.fetch(attrs, key) do
      {:ok, value} when value not in [nil, ""] -> value
      _ -> raise ArgumentError, "#{path}: missing required attribute #{inspect(key)}"
    end
  end
end
