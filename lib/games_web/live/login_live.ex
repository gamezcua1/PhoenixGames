defmodule GamesWeb.LoginLive do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    ~L"""
      
    <div>
      <label>You must first login</label>
      <%= f = form_for :user, "#", [phx_submit: :login] %>
        <%= label f, :name %>
        <%= text_input f, :name %>

        <%= submit "Save" %>
      </form>
    </div

    """
  end

end
