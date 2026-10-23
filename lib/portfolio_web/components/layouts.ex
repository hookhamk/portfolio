defmodule PortfolioWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use PortfolioWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  The page frame: site header and navigation, a centered column for the
  content, and a footer that says where the page was served from.

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  slot :inner_block, required: true

  def app(assigns) do
    assigns = assign(assigns, site: Portfolio.site(), region: Portfolio.runtime().region)

    ~H"""
    <header class="border-b border-base-300">
      <nav class="mx-auto flex max-w-3xl flex-wrap items-center gap-x-6 gap-y-2 px-4 py-4 sm:px-6">
        <.link navigate={~p"/"} class="mr-auto font-semibold">{@site.name}</.link>
        <.link navigate={~p"/work"} class="link link-hover">Work</.link>
        <.link navigate={~p"/log"} class="link link-hover">Log</.link>
        <.theme_toggle />
      </nav>
    </header>

    <main class="px-4 py-12 sm:px-6">
      <div class="mx-auto max-w-3xl space-y-12">
        {render_slot(@inner_block)}
      </div>
    </main>

    <footer class="border-t border-base-300">
      <div class="mx-auto flex max-w-3xl flex-wrap gap-x-6 gap-y-2 px-4 py-6 text-sm text-base-content/70 sm:px-6">
        <a :if={@site.linkedin_url} href={@site.linkedin_url} class="link link-hover">LinkedIn</a>
        <a :if={@site.github_url} href={@site.github_url} class="link link-hover">GitHub</a>
        <a :if={@site.email} href={"mailto:#{@site.email}"} class="link link-hover">Email</a>
        <.link navigate={~p"/colophon"} class="link link-hover ml-auto">
          {if @region, do: "Served from #{@region} on Fly.io", else: "About this site"}
        </.link>
      </div>
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
