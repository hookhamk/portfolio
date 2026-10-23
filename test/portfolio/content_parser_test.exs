defmodule Portfolio.ContentParserTest do
  use ExUnit.Case, async: true

  alias Portfolio.Content.{Entry, Parser, Project}

  @moduletag :tmp_dir

  defp write!(dir, name, contents) do
    path = Path.join(dir, name)
    File.write!(path, contents)
    path
  end

  test "parses attributes and renders markdown", %{tmp_dir: dir} do
    path =
      write!(
        dir,
        "site.md",
        ~s|%{title: "Site", kind: :website, summary: "One line"}\n---\n## Hello\n|
      )

    project = Project.parse!(path)

    assert project.slug == "site"
    assert project.title == "Site"
    assert project.status == :live
    assert project.body =~ "<h2"
    assert project.body =~ "Hello"
  end

  test "escapes raw HTML in the body", %{tmp_dir: dir} do
    path = write!(dir, "x.md", ~s|%{}\n---\n<script>alert(1)</script>\n|)

    {_attrs, html} = Parser.parse!(path)

    refute html =~ "<script>"
  end

  test "rejects a file without the --- separator", %{tmp_dir: dir} do
    path = write!(dir, "x.md", ~s|%{title: "x"}|)

    assert_raise ArgumentError, ~r/missing `---`/, fn -> Parser.parse!(path) end
  end

  test "rejects an unknown kind and names the file", %{tmp_dir: dir} do
    path = write!(dir, "bad.md", ~s|%{title: "x", kind: :webiste, summary: "y"}\n---\n|)

    assert_raise ArgumentError, ~r/bad\.md: kind must be one of/, fn -> Project.parse!(path) end
  end

  test "rejects a missing required attribute", %{tmp_dir: dir} do
    path = write!(dir, "p.md", ~s|%{title: "x", kind: :tool}\n---\n|)

    assert_raise ArgumentError, ~r/missing required attribute :summary/, fn ->
      Project.parse!(path)
    end
  end

  test "takes the entry date from the filename", %{tmp_dir: dir} do
    path =
      write!(dir, "2026-10-22-launch.md", ~s|%{title: "Launch", kind: :milestone}\n---\nHi\n|)

    entry = Entry.parse!(path)

    assert entry.date == ~D[2026-10-22]
    assert entry.slug == "2026-10-22-launch"
  end

  test "rejects an entry filename without a date", %{tmp_dir: dir} do
    path = write!(dir, "launch.md", ~s|%{title: "Launch", kind: :milestone}\n---\n|)

    assert_raise ArgumentError, ~r/must start with YYYY-MM-DD-/, fn -> Entry.parse!(path) end
  end
end
