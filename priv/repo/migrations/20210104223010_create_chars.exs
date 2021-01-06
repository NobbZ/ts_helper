defmodule TsHelper.Repo.Migrations.CreateChars do
  use Ecto.Migration

  def change do
    create table(:chars, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string

      timestamps()
    end

  end
end
