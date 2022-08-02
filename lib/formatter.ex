defmodule Logzio.Formatter do
  # Copied and inspired from https://github.com/Logflare/logflare_logger_backend/blob/3dd9de5d9e5ef039668e89405b66c9f1dab35346/lib/logflare_logger/log_params.ex
  # and
  # https://github.com/elixir-lang/elixir/blob/74bfab8ee271e53d24cb0012b5db1e2a931e0470/lib/logger/lib/logger/formatter.ex

  def format(lvl, msg, ts, md) do
    md
    |> metadata()
    |> Enum.into(%{level: lvl, message: to_string(msg), timestamp: format_timestamp(ts)})
    |> Jason.encode!()
  end

  @doc """
  Formats time as ISO8601 format.
  """
  def format_timestamp({date, {hour, minute, second}}) do
    format_timestamp({date, {hour, minute, second, 0}})
  end

  def format_timestamp({date, {hour, minute, second, {_micro, 6} = fractions_with_precision}}) do
    {date, {hour, minute, second}}
    |> NaiveDateTime.from_erl!(fractions_with_precision)
    |> NaiveDateTime.to_iso8601(:extended)
    |> Kernel.<>("Z")
  end

  def format_timestamp({date, {hour, minute, second, milli}}) when is_integer(milli) do
    erldt =
      {date, {hour, minute, second}}
      |> :calendar.local_time_to_universal_time_dst()
      |> case do
        [] -> {date, {hour, minute, second}}
        [dt_utc] -> dt_utc
        [_, dt_utc] -> dt_utc
      end

    erldt
    |> NaiveDateTime.from_erl!({milli * 1000, 6})
    |> NaiveDateTime.to_iso8601(:extended)
    |> Kernel.<>("Z")
  end

  defp metadata([{key, value} | md]) do
    if formatted = metadata(key, value) do
      [{to_string(key), formatted} | metadata(md)]
    else
      metadata(md)
    end
  end

  defp metadata([]), do: []

  defp metadata(:time, _), do: nil
  defp metadata(:gl, _), do: nil
  defp metadata(:report_cb, _), do: nil

  defp metadata(_, nil), do: nil
  defp metadata(_, string) when is_binary(string), do: string
  defp metadata(_, integer) when is_integer(integer), do: Integer.to_string(integer)
  defp metadata(_, float) when is_float(float), do: Float.to_string(float)
  # Preserve the actual pid format but as string : #PID<0.758.0>
  defp metadata(_, pid) when is_pid(pid), do: "#PID#{:erlang.pid_to_list(pid) |> to_string}"

  defp metadata(_, atom) when is_atom(atom) do
    case Atom.to_string(atom) do
      "Elixir." <> rest -> rest
      "nil" -> ""
      binary -> binary
    end
  end

  defp metadata(_, ref) when is_reference(ref) do
    '#Ref' ++ rest = :erlang.ref_to_list(ref)
    rest
  end

  defp metadata(:file, file) when is_list(file), do: file

  defp metadata(:domain, [head | tail]) when is_atom(head) do
    Enum.map_intersperse([head | tail], ?., &Atom.to_string/1)
  end

  defp metadata(:mfa, {mod, fun, arity})
       when is_atom(mod) and is_atom(fun) and is_integer(arity) do
    Exception.format_mfa(mod, fun, arity)
  end

  defp metadata(:initial_call, {mod, fun, arity})
       when is_atom(mod) and is_atom(fun) and is_integer(arity) do
    Exception.format_mfa(mod, fun, arity)
  end

  defp metadata(_, list) when is_list(list), do: nil

  defp metadata(_, other) do
    case String.Chars.impl_for(other) do
      nil -> nil
      impl -> impl.to_string(other)
    end
  end
end
