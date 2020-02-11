defmodule GamesWeb.TicTacToeController do
  use GamesWeb, :controller
  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    live_render(conn, GamesWeb.TicTacToeLive, session: %{})
  end
end
