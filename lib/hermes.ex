defmodule Hermes do
  @registry Hermes.Registry
  @pg_group {:hermes, Hermes.PubSub}

  def subscribe(topic) when is_atom(topic) do
    Registry.register(@registry, topic, nil)
  end

  def publish(topic, message) when is_atom(topic) do
    for pid <- :pg.get_members(@pg_group), node(pid) != node() do
      send(pid, {:broadcast_to_local, topic, message})
    end

    broadcast(:local, topic, message)
  end

  def broadcast(:local, topic, message) when is_atom(topic) do
    Registry.dispatch(@registry, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, message)
    end)
  end
end
