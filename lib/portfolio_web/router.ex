defmodule PortfolioWeb.Router do
  use PortfolioWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PortfolioWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # Fly health checks hit this; no session or layout needed.
  scope "/", PortfolioWeb do
    get "/healthz", HealthController, :show
  end

  scope "/", PortfolioWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/colophon", PageController, :colophon

    get "/work", WorkController, :index
    get "/work/:slug", WorkController, :show

    get "/log", LogController, :index
    get "/log/:slug", LogController, :show
  end
end
