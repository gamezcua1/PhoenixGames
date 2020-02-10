defmodule GamesWeb.TicTacToeLive do
  use Phoenix.LiveView

  alias Games.TTTRooms

  def render(%{room: {status, room_name}, username: username} = assigns) do
    ~L"""
    
    <h1>TicTacToe</h1>
    <p>Welcome <%= username %> your status is: <%= status %></p>

    """
  end

  def render(assigns) do
    ~L"""

    <%= live_component @socket, GamesWeb.LoginLive %>

    """
  end

  def mount(_params, _assigns, socket) do
    {:ok, socket}
  end

  def handle_event("login", %{"user" => %{"name" => name}}, socket) when name != ""  do
    room = TTTRooms.find_empty_room(name)

    {:noreply, assign(socket, username: name, room: room)}
  end

end
