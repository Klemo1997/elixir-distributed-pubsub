defmodule Hermes do
  @registry Hermes.Registry

  def subscribe(topic) when is_atom(topic) do
    Registry.register(@registry, topic, nil)
  end

  def publish(topic, message) when is_atom(topic) do
    Registry.dispatch(@registry, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, message)
    end)
  end
end
