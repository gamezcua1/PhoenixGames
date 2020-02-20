defmodule Games.HangmanRooms do
  use Agent

  @room %{
    name: "",
    participants: [],
    word: [],
    word_process: [],
    turn: "",
    number_participants: 0
  }

  # ServerSide

  def start_link(_) do
    IO.puts("Games.GangmanRooms started")
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # Client-Side

  def get_rooms do
    Agent.get(__MODULE__, & &1)
  end

  def get_room(name) do
    Agent.get(__MODULE__, & &1[name])
  end

  def join_room(room_name, username) do
    get_room(room_name)
    |> change_room(username)
    |> save_room
  end

  def join_room(username), do: join_room(nil, username)

  def make_guess(room, user, guess) do
    do_guess(room, user, guess)
  end

  def explode do
    Agent.update(__MODULE__, fn _ -> %{} end)
  end

  # privates

  defp save_room(room) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, room.name, room)
    end)

    notify_hall(get_rooms())
    notify_room(room)

    room
  end

  defp change_room(nil, username) do
    @room
    |> Map.put(:name, Faker.StarWars.planet())
    |> Map.put(:participants, [username])
    |> Map.put(:number_participants, 1)
    |> Map.put(:turn, username)
    |> put_word
    |> set_timer
  end

  defp change_room(room, username) do
    room
    |> Map.put(:participants, [username | room.participants])
    |> Map.put(:number_participants, room.number_participants + 1)
  end

  defp put_word(room) do
    random_word =
      Faker.Pokemon.name()
      |> String.split("-")
      |> hd
      |> String.downcase()
      |> String.graphemes()

    room
    |> Map.put(:word, random_word)
    |> Map.put(:word_process, String.duplicate("_", length(random_word)) |> String.graphemes())
  end

  defp put_turn(room, user) do
    user_index = Enum.find_index(room.participants, fn participant -> participant == user end) + 1

    user_index =
      if user_index == length(room.participants) do
        0
      else
        user_index
      end

    next_turn = Enum.at(room.participants, user_index)
    Map.put(room, :turn, next_turn)
  end

  defp do_guess(%{turn: turn} = room, user, guess) do
    new_word_process =
      Enum.with_index(room.word)
      |> Enum.map(fn {char, i} ->
        if char != guess do
          Enum.at(room.word_process, i)
        else
          guess
        end
      end)

    room
    |> Map.put(:word_process, new_word_process)
    |> put_turn(user)
    |> save_room
  end

  defp do_guess(room, _, _) do
    IO.inspect room
    {:error, :not_your_turn}
  end

  defp set_timer(room) do
    spawn(fn -> loop_timer(room.name) end)

    room
  end

  defp loop_timer(room_name) do
    :timer.sleep(1000)

    room = get_room(room_name)

    put_turn(room, room.turn)
    |> save_room

    loop_timer(room_name)
  end

  defp notify_hall(rooms) do
    GamesWeb.Endpoint.broadcast!("hangman_hall", "new_room", %{rooms: rooms})
  end

  defp notify_room(%{name: name} = room) do
    GamesWeb.Endpoint.broadcast!("hm_#{name}", "game_status", %{room: room})
  end

end
