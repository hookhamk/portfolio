defmodule Portfolio do
  @moduledoc """
  Site-wide settings and facts about where the site is running.
  """

  @doc "Site settings from `config :portfolio, :site`."
  def site, do: Map.new(Application.fetch_env!(:portfolio, :site))

  @doc """
  Where this response was rendered. Fly sets these variables on every Machine;
  locally they are nil.
  """
  def runtime do
    %{
      app: System.get_env("FLY_APP_NAME"),
      region: System.get_env("FLY_REGION"),
      machine_id: System.get_env("FLY_MACHINE_ID"),
      image: System.get_env("FLY_IMAGE_REF"),
      release: Application.spec(:portfolio, :vsn) |> to_string(),
      elixir: System.version(),
      otp: System.otp_release()
    }
  end
end
