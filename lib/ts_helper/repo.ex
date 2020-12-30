defmodule TsHelper.Repo do
  use Ecto.Repo,
    otp_app: :ts_helper,
    adapter: Ecto.Adapters.Postgres
end
