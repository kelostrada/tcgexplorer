# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tcg_explorer,
  ecto_repos: [TcgExplorer.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :tcg_explorer, TcgExplorerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8BzEpdZ+5bLtjg8mXfdXygfmQJZdW4wrTgaH/QcgTSxszdZMe24svUIKVk5EZquh",
  render_errors: [view: TcgExplorerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TcgExplorer.PubSub,
  live_view: [signing_salt: "POJmoMVl"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
