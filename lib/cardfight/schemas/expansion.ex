defmodule Cardfight.Expansion do
  use Cardfight.Schema

  schema "expansions" do
    field(:code, :string)
    field(:name, :string)
    has_many(:cards, Cardfight.Card)

    timestamps()
  end

  def changeset(schema, changes) do
    schema
    |> cast(changes, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code)
    |> unique_constraint(:name)
  end
end
