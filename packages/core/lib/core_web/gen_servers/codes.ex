defmodule CoreWeb.GenServers.Codes do
  use GenServer

  @name {:global, __MODULE__}

  # Client
  def start_server() do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end


  def get_room_id_by_code(code) when is_binary(code) do
    GenServer.call(@name, {:get_room_id_by_code, code})
  end

  def put({code, roomId}) do
    GenServer.cast(@name, {:put, code, roomId})
  end

  # Server
  @impl GenServer
  def init(_state) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:get_room_id_by_code, code}, _from, state) do
    room_id = Map.get(state, code, nil)

    {:reply, room_id, state}
  end

  @impl GenServer
  def handle_cast({:put, code, room_id}, state) do
    {:noreply, Map.put(state, code, room_id)}
  end
end
