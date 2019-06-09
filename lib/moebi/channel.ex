defmodule Moebi.Channels do
  def create_and_invite(channel, user) do
    create(channel)
    |> invite(user)
  end

  @callback create(String.t()) :: tuple()
  def create(channel_name) do
    case Slack.Web.Channels.create(channel_name) do
      %{"ok" => true, "channel" => channel} ->
        {:ok, %{id: channel["id"], name: channel["name_normalized"]}}

      %{"ok" => false, "error" => error} ->
        {:error, "could not create channel #{error}"}
    end
  end

  @callback create(tuple(), String.t()) :: tuple()
  def invite({:ok, channel}, user) do
    case Slack.Web.Channels.invite(channel.id, user) do
      %{"ok" => true} -> {:ok, channel}
      %{"ok" => false, "error" => error} -> {:error, "could not invite user #{error}"}
    end
  end

  def invite({:error, error}, _user) do
    {:error, error}
  end
end
