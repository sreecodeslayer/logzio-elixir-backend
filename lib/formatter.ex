defmodule Logzio.Formatter do
  def format(lvl, msg, ts, metadata),
    do: metadata |> Map.merge(%{level: lvl, message: msg, timestamp: ts}) |> Jason.encode!()
end
