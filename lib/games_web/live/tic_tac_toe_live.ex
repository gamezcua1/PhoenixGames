defmodule GamesWeb.TicTacToeLive do
  use Phoenix.LiveView

  alias Games.TTTRooms

  @board %{
    "1" => nil, "2" => nil, "3" => nil,
    "4" => nil, "5" => nil, "6" => nil,
    "7" => nil, "8" => nil, "9" => nil
  }

  def render(%{game_status: status, board: board, room: room_name, username: username, type: type, turn: turn} = assigns) do
    ~L"""
    
    <h1>TicTacToe</h1>
    <p>Welcome <%= username %> your status is: <%= status %></p>
    <label>room: <%= room_name %> tile: <%= type %></label>

    <%= if status == :started do %>
      <%= live_component @socket, GamesWeb.TTT.Board, board: board, turn: turn %>
    <% end %>

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
    {status, room_name} = TTTRooms.find_empty_room(name)

    GamesWeb.Endpoint.subscribe("ttt_#{room_name}")

    GamesWeb.Endpoint.broadcast!("ttt_#{room_name}", "game_started", %{game_status: status})

    {:noreply, assign(socket, username: name, room: room_name, game_status: :error)}
  end

  def handle_event("choose_tile", %{"value" => id}, %{assigns: %{type: type, room: room}} = socket) do
    GamesWeb.Endpoint.broadcast!("ttt_#{room}", "choose_made", %{id: id, type: type})

    {:noreply, socket}
  end

  def handle_info(%{event: "game_started", payload: %{game_status: :found}}, %{assigns: %{type: type}} = socket) when type != nil  do
    {:noreply, assign(socket, game_status: :started, board: @board)}
  end

  def handle_info(%{event: "game_started", payload: %{game_status: :found}}, socket) do
    {:noreply, assign(socket, game_status: :started, type: :o, board: @board, turn: false)}
  end

  def handle_info(%{event: "game_started", payload: %{game_status: :not_found}}, socket) do
    {:noreply, assign(socket, game_status: :waiting, type: :x, board: @board, turn: true)}
  end

  def handle_info(%{event: "choose_made", payload: %{id: id, type: type}}, %{assigns: %{board: board, type: user_type}} = socket) do
    new_board = Map.put(board, id, type)
    is_turn = type != user_type

    {:noreply, assign(socket, board: new_board, turn: is_turn)}
  end

end
