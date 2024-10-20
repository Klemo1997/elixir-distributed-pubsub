# A distributed PubSub service for learning purposes

## Disclaimer
This project is meant solely for learning purposes and not to be used in production. If you need a distributed PubSub for production, just use the already battle-tested [Phoenix.PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html).

## Details

This is a sample project for working distributed PubSub (Publisher-Subscriber) service, inspired by [Phoenix.PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html). It is highly suitable for asynchronous Event-Driven architecture. The communication is handled through the `Hermes` module, which has access to the defined process group (see: [Process Groups](https://www.erlang.org/doc/apps/kernel/pg.html)). Through them, the `Hermes` module distributes the message to other nodes, and they handle it through the `Hermes.PGServer` module, which accepts the event from other Node, and distributes it locally to prevent linear growth of traffic depending on number of subscribers.

Project is a follow-up of this wonderful [article](https://papers.vincy.dev/distributed-pubsub-in-elixir).

## PoC Demonstration

```sh
# Node: Alice
iex --sname alice -S mix

# Node: Bob
iex --sname bob -S mix

# Node: Carol
iex --sname carol -S mix
```

Libcluster automatically discovers and connects these local nodes.

For this test, we’ll have the following:
    - Alice:
        - 1 client subscribed to `:user_created`
        - 1 client subscribed to `:user_updated`
    - Bob:
        - 5 clients subscribed to `:user_created`
        - 0 clients subscribed to `:user_updated`
    - Carol:
        - 0 clients subscribed to `:user_created`
        - 2 clients subscribed to `:user_updated`

```sh
# Node: Alice
iex(alice@ae691cef1738)1> Client.start_link(:user_created)
{:ok, #PID<0.214.0>}
iex(alice@ae691cef1738)2> Client.start_link(:user_updated)
{:ok, #PID<0.215.0>}

# Node: Bob
iex(bob@ae691cef1738)1> for _ <- 1..5, do: Client.start_link(:user_created)
[
  ok: #PID<0.201.0>,
  ok: #PID<0.202.0>,
  ok: #PID<0.203.0>,
  ok: #PID<0.204.0>,
  ok: #PID<0.205.0>
]

# Node: Carol
iex(carol@ae691cef1738)1> for _ <- 1..2, do: Client.start_link(:user_updated)
[ok: #PID<0.197.0>, ok: #PID<0.198.0>]
```

Publishing a `:user_created` message from `Alice`:

```sh
# Node: Alice
iex(alice@ae691cef1738)3> Hermes.publish(:user_created, %{name: "Jade"})
:ok
Received: %{name: "Jade"}

# Node: Bob
Received: %{name: "Jade"}
Received: %{name: "Jade"}
Received: %{name: "Jade"}
Received: %{name: "Jade"}
Received: %{name: "Jade"}

# Node: Carol
# ** nothing new **
```

Now, let’s try publishing a `:user_updated` message from Bob:

```sh
# Node: Alice
Received: %{id: 1, name: "Jadyline"}

# Node: Bob
iex(bob@ae691cef1738)2> Hermes.publish(:user_updated, %{id: 1, name: "Jadyline"})
:ok

# Node: Carol
Received: %{id: 1, name: "Jadyline"}
Received: %{id: 1, name: "Jadyline"}
```