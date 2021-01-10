defmodule TsHelper.Repo.Migrations.InsertTrades do
  use Ecto.Migration

  alias TsHelper.Repo
  
  @trades ~W[Other Science Fauna Flora Fashioning Metal Stone Wood Sociability]

  # This migration only works if the correct extension is available in the database.
  # CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public
  def up do
    Repo.insert_all(
      "trades",
      Enum.map(@trades, &%{ name: &1})
    )
  end

  def down do
    @trades
    |> Enum.each(fn trade ->
      Repo.query(~S'DELETE FROM "trades" WHERE name = $1', [trade])
    end)
  end
end
