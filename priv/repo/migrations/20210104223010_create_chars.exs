defmodule TsHelper.Repo.Migrations.CreateChars do
  use Ecto.Migration

  def change do
    create table(:chars, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :name, :string

      timestamps()
    end
  end
end
