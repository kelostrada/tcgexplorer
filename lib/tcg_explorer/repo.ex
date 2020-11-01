defmodule TcgExplorer.Repo do
  use Ecto.Repo,
    otp_app: :tcg_explorer,
    adapter: Ecto.Adapters.Postgres
end
