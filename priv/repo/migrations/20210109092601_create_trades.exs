defmodule TsHelper.Repo.Migrations.CreateTrades do
  use Ecto.Migration

  def change do
    create table(:trades, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :name, :string

      timestamps(default: fragment("NOW()"))
    end
  end
end
