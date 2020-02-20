defmodule GamesWeb.RoomsList do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(%{rooms: rooms} = assigns) do
    ~L"""
      <%= for {_key, %{name: name, number_participants: n}} <- rooms do %>
        <button phx-click="join_room" value="<%= name %>"><%= name %> [<%= n %>]</button>
      <% end %>
    """
  end
end
