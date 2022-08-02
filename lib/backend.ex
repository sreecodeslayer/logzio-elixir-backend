defmodule Logzio.Backend do
  @behaviour :gen_event

  @impl true
  def init({__MODULE__, :logzio}) do
    {:ok, configure(:logzio, [])}
  end

  @impl true
  def handle_call({:configure, opts}, %{name: name} = state) do
    {:ok, :ok, configure(name, opts, state)}
  end

  # Handle the flush event
  @impl true
  def handle_event(:flush, state) do
    {:ok, state}
  end

  @impl true
  def handle_event({_, gl, _}, state) when node(gl) != node() do
    {:ok, state}
  end

  @impl true
  def handle_event({lvl, _gl, {Logger, msg, ts, metadata}}, state) do
    if log_level_matches?(lvl, state.level) do
      Logzio.Formatter.format(lvl, msg, ts, metadata)
    end

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

  defp log_level_matches?(_lvl, nil), do: true
  defp log_level_matches?(lvl, min), do: Logger.compare_levels(lvl, min) != :lt
end
