# Logzio elixir backend
Elixir logging backend that sends your logs to Logz.io using the https bulk input 

## Installation

The package can be installed by adding `logzio` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logzio, "~> 0.1.0"}
  ]
end
```

## Usage
If you do not already have a Logz.io account, please signup for one and obtain the following details:
1. Listener host
2. Data shipping token

Once you have these, you are all set to integrate your Elixir app with Logzio.

```elixir
# config/releases.exs
config :logger, 
  level: :info, 
  backends: [:console, {Logzio.Backend, :logzio}]

config :logger, 
  logzio: [
    token: System.get_env("LOGZIO_TOKEN"),
    base_url: System.get_env("LOGZIO_BASE_URL", "https://listener.logz.io:8071/")
  ]
```

That's it. You should now be able to see your app logs by heading over to [logz.io](https://logz.io)!

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/logzio](https://hexdocs.pm/logzio).
