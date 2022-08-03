defmodule Logzio.MixProject do
  use Mix.Project

  def project do
    [
      app: :logzio,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      source_url: "https://github.com/sreecodeslayer/logzio-elixir-backend",
      name: "Logzio",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.0"}
    ]
  end

  defp description do
    "Elixir logging backend that sends your logs to Logz.io using the https bulk API"
  end

  defp package do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: [" LGPL-2.1-only"],
      links: %{"GitHub" => "https://github.com/sreecodeslayer/logzio-elixir-backend"}
    ]
  end
end
