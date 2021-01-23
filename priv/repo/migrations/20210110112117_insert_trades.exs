defmodule TsHelper.Repo.Migrations.InsertTrades do
  use Ecto.Migration

  import Ecto.Query

  alias TsHelper.Repo

  @trades ~W[Other Science Fauna Flora Fashioning Metal Stone Wood Sociability]
  @trade_count Enum.count(@trades)

  # This migration only works if the correct extension is available in the database.
  # CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public
  def up do
    {@trade_count, _} = Repo.insert_all("trades", Enum.map(@trades, &%{name: &1}))
  end

  def down do
    {@trade_count, _} = from(t in "trades", where: t.name in @trades) |> Repo.delete_all()
  end
end
