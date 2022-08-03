defmodule Logzio do
  @logzio_type "http-bulk"

  def send(messages) do
    json_lines = Enum.join(messages, "\n")

    case HTTPoison.post(url(), json_lines, default_headers()) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        unless code in 200..299 do
          IO.warn(
            "Logzio API warning: Dropping Logs: HTTP response status is #{code}. Response body is: #{inspect(body)}"
          )
        end

      {:error, reason} ->
        IO.warn(
          "Logzio API warning: Dropping Logs: HTTP request failed due to: #{inspect(reason)}"
        )
    end
  end

  def url() do
    "#{config(:base_url)}?token=#{config(:token)}&type=#{@logzio_type}"
  end

  def default_headers do
    [
      {"content-type", "text/plain"},
      {"user-agent", "elixir-client/v#{Application.spec(:logzio, :vsn)}"}
    ]
  end

  defp config(:token) do
    configs = Application.get_env(:logger, :logzio)
    Keyword.fetch!(configs, :token)
  end

  defp config(:base_url) do
    configs = Application.get_env(:logger, :logzio)
    Keyword.fetch!(configs, :base_url)
  end
end
