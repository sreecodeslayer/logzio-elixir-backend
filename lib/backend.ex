defmodule Logzio.Backend do
  @behaviour :gen_event

  @impl true
  def init({__MODULE__, :logzio}) do
    {:ok, configure(:logzio, [])}
  end

  # Handle the flush event
  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_call({:configure, opts}, %{name: name} = state) do
    {:ok, :ok, configure(name, opts, state)}
  end

  def handle_event({lvl, _gl, {Logger, msg, ts, metadata}}, state) do
    Logzio.Formatter.format(lvl, msg, ts, metadata) |> IO.puts()
    {:ok, state}
  end

  defp configure(name, []) do
    default_level = Application.get_env(:logger, :level, :debug)
    Application.get_env(:logger, name, []) |> Enum.into(%{name: name, level: default_level})
  end

  defp configure(_name, [level: new_level], state) do
    Map.merge(state, %{level: new_level})
  end

  defp configure(_name, _opts, state), do: state
end
