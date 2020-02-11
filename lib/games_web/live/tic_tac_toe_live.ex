defmodule GamesWeb.TicTacToeLive do
  use Phoenix.LiveView

  alias Games.TTTRooms

  @board %{
    "1" => nil, "2" => nil, "3" => nil,
    "4" => nil, "5" => nil, "6" => nil,
    "7" => nil, "8" => nil, "9" => nil
  }

  @tests [
    ["1", "2", "3"],
    ["4", "5", "6"],
    ["7", "8", "9"],
    ["1", "4", "7"],
    ["2", "5", "8"],
    ["3", "6", "9"],
    ["1", "5", "9"],
    ["7", "5", "3"]
  ]

  def render(%{game_status: status, board: board, room: room_name, username: username, type: type, turn: turn, game_won: game_won} = assigns) when game_won != true do
    ~L"""

    <h1>TicTacToe</h1>
    <p>Welcome <%= username %> your status is: <%= status %></p>
    <label>room: <%= room_name %> tile: <%= type %></label>

    <%= if status == :started do %>
      <%= live_component @socket, GamesWeb.TTT.Board, board: board, turn: turn %>
      <% end %>

    """
  end

  def render(%{game_won: true, winner: winner} = assigns) do
    ~L"""
      
      <h1>TicTacToe</h1>
      <p><%= winner %> wins</p>

      <%= live_component @socket, GamesWeb.LoginLive %>

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
    {:noreply, assign(socket, game_status: :started, board: @board, game_won: false)}
  end

  def handle_info(%{event: "game_started", payload: %{game_status: :found}}, socket) do
    {:noreply, assign(socket, game_status: :started, type: :o, board: @board, turn: false, game_won: false)}
  end

  def handle_info(%{event: "game_started", payload: %{game_status: :not_found}}, socket) do
    {:noreply, assign(socket, game_status: :waiting, type: :x, board: @board, turn: true, game_won: false)}
  end

  def handle_info(%{event: "choose_made", payload: %{id: id, type: type}}, %{assigns: %{board: board, type: user_type}} = socket) do
    new_board = Map.put(board, id, type)
    is_turn = type != user_type
    game_won = has_winner(new_board)
    winner = if game_won, do: type, else: false

    {:noreply, assign(socket, board: new_board, turn: is_turn, game_won: game_won, winner: winner)}
  end

  defp has_winner(board) do
    Enum.find(@tests, fn [p1, p2, p3] -> board[p1] == board[p2] && board[p1] == board[p3] && board[p1] != nil end) != nil
  end

end
