defmodule Hermes.PGServer do
  use GenServer

  def start_link(_), do: GenServer.start_link(Hermes.PGServer, [], name: Hermes.PGServer)

  @impl GenServer
  def init(_args) do
    :pg.start_link()
    :pg.join({:hermes, Hermes.PubSub}, self())

    {:ok, []}
  end

  @impl GenServer
  def handle_info({:broadcast_to_local, topic, message}, state) do
    Hermes.broadcast(:local, topic, message)
    {:noreply, state}
  end
end
