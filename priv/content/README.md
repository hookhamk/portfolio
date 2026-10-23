# Content

Everything on the site comes from this folder. Each file is an Elixir map of
attributes, a line with `---`, then Markdown. The build fails with the file
name if something is wrong (a missing title, a typo in `kind`, a log entry that
points at a project that doesn't exist), so a broken file never reaches the site.

Files starting with `_` are templates and are never published. Copy one to start.

| Folder | What goes there | URL |
|---|---|---|
| `projects/<slug>.md` | One piece of work: a website, a system, a tool | `/work/<slug>` |
| `log/YYYY-MM-DD-<slug>.md` | A dated change, milestone, or lesson learned | `/log/YYYY-MM-DD-<slug>` |
| `pages/home.md`, `pages/colophon.md` | Home page intro, "About this site" text | `/`, `/colophon` |

## Drafts

`draft: true` keeps a file off the live site. In dev (`mix phx.server`) drafts
show with a "Draft" badge so you can preview them. Delete the line, or set it
to `false`, to publish.

## History

A project's page shows every log entry whose `project:` matches its slug,
newest first. That list is the project's history: add an entry when you ship
something, change direction, or learn something worth keeping. Git keeps the
history of the files themselves.

## Projects

```elixir
%{
  title: "Haunted 365",
  kind: :website,              # :website | :infrastructure | :tool | :other
  summary: "One line, shown on cards and in LinkedIn previews.",
  role: "Founder, architect, developer",
  status: :live,               # :live | :in_progress | :paused | :retired | :private
  started: "2025-03",          # YYYY-MM, used for sorting
  ended: nil,
  stack: ["Phoenix", "LiveView", "Postgres"],
  links: [{"Live site", "https://example.com"}],
  featured: true,              # shown on the home page
  draft: false
}
---
Markdown body.
```

## Log entries

```elixir
%{
  title: "Moved sessions to signed cookies",
  kind: :change,               # :change | :milestone | :lesson
  project: "haunted-365",      # optional; must match a file in projects/
  summary: "Optional one line for lists and link previews.",
  draft: false
}
---
Markdown body.
```

## Before publishing anything about the network

Write about decisions, not a map. Leave out server counts, hostnames, IPs,
providers, and which machine does what. "The database never touches the public
internet, and here's why I chose that" is fine; "the DB server is box 7 on
Tailscale" is not.
