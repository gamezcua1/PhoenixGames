defmodule GamesWeb.TTT.Board do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(%{board: board, turn: turn} = assigns) do
    ~L"""

    <div>
    <h1>Let's play</h1>

    <%= for row <- Enum.chunk_every(board, 3) do %>

      <div>
      <%= for {i, tile} <- row do %>
        <%= if tile == nil && turn do %>
          <button phx-click="choose_tile" value="<%= i %>">-</button>
          <% else %>
            <button disabled="true"><%= tile || "-" %></button>
          <% end %>
        <% end %>
      </div>


      <% end %>

    </div>

    """
  end
end
