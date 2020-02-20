defmodule GamesWeb.HangmanLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias Games.HangmanRooms

  def render(%{user: user, room: room} = assigns) do
    ~L"""
      <h1>Hangman</h1>
      <h5>Welcome <%= user %> you are part of <%= room.name %></h5>
      <p><%= room.turn %>'s turn</p>

      
      <h3><%= room.word_process |> Enum.join %></h3>

      <%= f = form_for :hangman, "#", [phx_submit: :make_guess] %>
        <%= label f, :guess %>
        <%= text_input f, :guess, [disabled: room.turn != user] %>

        
        <%= submit "Guess", [disabled: room.turn != user] %>
      </form>

    """
  end

  def render(%{user: user, available_rooms: rooms} = assigns) do
    ~L"""
      <h1>Hangman</h1>
      <h5>Welcome <%= user %> these are the available rooms</h5>

      <button class="button button-clear" phx-click="join_room">New Room</button>
      <br>
      <br>

      <button class="button button-outline"><%= length Map.keys rooms %></button>
      <br>
      <%= live_component @socket, GamesWeb.RoomsList, rooms: rooms %>

    """
  end

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
    GamesWeb.Endpoint.subscribe("hangman_hall")

    rooms = HangmanRooms.get_rooms
    {:noreply, assign(socket, available_rooms: rooms, user: name)}
  end

  def handle_event("join_room", %{"value" => ""}, %{assigns: %{user: user}} = socket) do
    handle_join_room(socket, user)
  end

  def handle_event("join_room", %{"value" => room_name}, %{assigns: %{user: user}} = socket) do
    handle_join_room(socket, user, room_name)  
  end

  def handle_event("make_guess", %{"hangman" => %{"guess" => guess}}, socket) when guess != "" do
    %{assigns: %{room: room, user: user}} = socket

    IO.inspect HangmanRooms.make_guess(room, user, guess)

    {:noreply, socket}    
  end

  def handle_info(%{event: "new_room", payload: %{rooms: rooms}}, socket) do
    {:noreply, assign(socket, available_rooms: rooms)}
  end

  def handle_info(%{event: "game_status", payload: %{room: room}}, socket) do
    {:noreply, assign(socket, room: room)}
  end

  defp handle_join_room(socket, username, room_name \\ nil) do
    room = HangmanRooms.join_room room_name, username

    GamesWeb.Endpoint.unsubscribe("hangman_hall")
    GamesWeb.Endpoint.subscribe("hm_#{room.name}")

    {:noreply, assign(socket, room: room)}
  end


end
