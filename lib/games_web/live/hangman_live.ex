defmodule GamesWeb.HangmanLive do
  use Phoenix.LiveView
  
  def render(assigns) do
    ~L"""
      <h1>Hangman</h1>

      <%= live_component @socket, GamesWeb.LoginLive %>
    """
  end

  def mount(_params, _assigns, socket) do
    {:ok, socket}
  end

  def handle_event("login", %{"user" => %{"name" => name}}, socket) when name != "" do
    {:noreply, socket}
  end

end
