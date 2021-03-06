defmodule GamesWeb.Router do
  use GamesWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phoenix.LiveView.Flash
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GamesWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/tictactoe", TicTacToeController, :index

    get "/hangman", HangmanController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", GamesWeb do
  #   pipe_through :api
  # end
end
