defmodule PhoenixExrethinkdbChat.RoomChannel do
  use Phoenix.Channel
  require Logger
  alias Exrethinkdb.Query
  alias PhoenixExrethinkdbChat.Repo

  def join("rooms:lobby", message, socket) do
    send(self, :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    q = Query.table("messages")
    result = Repo.run(q)

    Enum.each(result.data, fn message -> push socket, "new_msg", message end)

    changes = Query.changes(q)
    |> Repo.run
    Task.async fn ->
      Enum.each(changes, fn change ->
        push socket, "new_msg", change["new_val"]
      end)
    end

    {:noreply, socket}
  end

  def handle_in("new_msg", msg, socket) do
    IO.inspect msg
    q = Query.table("messages")
    |> Query.insert(%{user: msg["user"], body: msg["body"]})
    Repo.run(q)

    {:reply, :ok, assign(socket, :user, msg["user"])}
  end

end
