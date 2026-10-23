defmodule Portfolio.ContentTest do
  # Toggles application env, so not async.
  use ExUnit.Case, async: false

  alias Portfolio.Content

  setup do
    previous = Application.get_env(:portfolio, :show_drafts)
    on_exit(fn -> Application.put_env(:portfolio, :show_drafts, previous) end)
  end

  test "hides drafts unless show_drafts is on" do
    Application.put_env(:portfolio, :show_drafts, false)
    published = Content.projects()
    refute Enum.any?(published, & &1.draft)
    refute Enum.any?(Content.entries(), & &1.draft)

    Application.put_env(:portfolio, :show_drafts, true)
    all = Content.projects()
    assert published -- all == []
    assert Enum.all?(all -- published, & &1.draft)
  end

  test "entries are newest first" do
    Application.put_env(:portfolio, :show_drafts, true)
    dates = Enum.map(Content.entries(), & &1.date)

    assert dates == Enum.sort(dates, {:desc, Date})
  end

  test "unknown slugs raise a 404 error" do
    assert_raise Content.NotFoundError, fn -> Content.get_project!("does-not-exist") end
    assert_raise Content.NotFoundError, fn -> Content.get_entry!("does-not-exist") end
  end
end
