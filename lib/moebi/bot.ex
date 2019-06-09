defmodule Moebi.Bot do
  use Slack
  alias Moebi.Channels

  @bot_user_id Application.get_env(:bot_user_id)

  def token, do: Application.get_env(:moebi, :slack_bot_token)

  def handle_connect(slack, state) do
    IO.puts("Connected as #{slack.me.name}")
    {:ok, state}
  end

  def handle_event(message = %{type: "message", text: "<@#{@bot_user_id}> " <> msg}, slack, state)
      when msg == "hi" do
    IO.inspect(message)
    IO.puts("Received message from Slack")
    send_message("oh hey! What's Slack? Can I sit on your lap?", message.channel, slack)
    {:ok, state}
  end

  def handle_event(message = %{type: "message", text: "<@#{@bot_user_id}> " <> msg}, slack, state)
      when msg == "park?" do
    case Channels.create_and_invite(channel_name(), @bot_user_id) do
      {:ok, channel} ->
        send_message("created channel #{escape_channel(channel)}!", message.channel, slack)

      {:error, error} ->
        send_message(error, message.channel, slack)
    end

    {:ok, state}
  end

  def handle_event(
        message = %{type: "message", subtype: "channel_join", text: "<@#{@bot_user_id}> " <> _msg},
        slack,
        state
      ) do
    send_message("Omg yay park park park!!", message.channel, slack)
    {:ok, state}
  end

  def handle_event(
        message = %{type: "message", text: "<@#{@bot_user_id}> " <> _msg},
        slack,
        state
      ) do
    IO.inspect(message)
    send_message("Ummm? Sorry? I don't know what that means. Did you mean chicken?", message.channel, slack)
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    IO.puts("Sending your message, captain!")

    send_message(text, channel, slack)

    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}

  defp channel_name do
    datetime =
      Date.utc_today()
      |> Date.to_string()
      |> String.replace(" ", "-")

    "moebi-#{datetime}-#{UUID.uuid1()}"
  end

  defp escape_channel(%{id: id, name: name}) do
    "<##{id}|#{name}>"
  end
end
