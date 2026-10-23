# Portfolio

Personal site: projects, a dated log of changes and lessons learned, and an
"About this site" page that shows which Fly.io Machine served the request.

Phoenix with no database. Content is Markdown in [`priv/content`](priv/content/README.md),
compiled into the app at build time, so a bad file fails the build instead of
breaking a page.

## Run it

```sh
mix setup
mix phx.server        # http://localhost:4000, drafts visible
mix test
```

## Write

See [`priv/content/README.md`](priv/content/README.md). Copy a `_template.md`,
fill it in, and remove `draft: true` when it's ready.

## Deploy (Fly.io, `projects` org)

First time:

```sh
fly apps create kelly-hookham --org projects   # or change `app` in fly.toml
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret) -a kelly-hookham
fly deploy
```

After that, `fly deploy` ships content and code changes.

Custom domain:

```sh
fly certs add example.com -a kelly-hookham
```

Then add the DNS records it prints, and set `PHX_HOST` in `fly.toml` to the domain.
# portfolio
