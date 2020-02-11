defmodule Games.TTTRooms do
  use Agent

  def start_link(_) do
    IO.puts("Games.TTTRooms started")
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_rooms do
    Agent.get(__MODULE__, & &1)
  end

  def new_room(username) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, username, false)
    end)
  end

  def occupy_room({name, _state}, _) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, name, true)
    end)

    {:found, name}
  end

  def occupy_room(nil, name) do
    new_room(name)
    {:not_found, name}
  end

  def find_empty_room(name) do
    Enum.find(get_rooms(), fn {_oponent, state} -> !state end)
    |> occupy_room(name)
  end

  def explode do
    Agent.update(__MODULE__, fn _ -> %{} end)
  end
end
