defmodule TsHelper.Avatars.Char do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chars" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(char, attrs) do
    char
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
