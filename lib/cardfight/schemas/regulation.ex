defmodule Cardfight.Regulation do
  use Cardfight.Schema

  schema "regulations" do
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
