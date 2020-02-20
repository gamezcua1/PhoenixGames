defmodule GamesWeb.HangmanController do
  use GamesWeb, :controller

  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    live_render(conn, GamesWeb.HangmanLive, session: %{})
  end
end
