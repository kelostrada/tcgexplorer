defmodule Cardfight.Type do
  use Cardfight.Schema
  import Ecto.Changeset

  schema "types" do
    field(:name, :string)
    has_many(:cards, Cardfight.Card)

    timestamps()
  end

  def changeset(schema, changes) do
    schema
    |> cast(changes, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
