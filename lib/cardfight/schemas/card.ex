defmodule Cardfight.Card do
  use Cardfight.Schema

  @fields ~w(number name image image_small grade power critical shield effect flavor)a
  @assocs ~w(expansion type clan race nation skill gift regulation rarity illustrator)a

  schema "cards" do
    field(:number, :string)
    field(:name, :string)
    field(:image, :string)
    field(:image_small, :string)
    field(:grade, :integer)
    field(:power, :integer)
    field(:critical, :integer)
    field(:shield, :integer)
    field(:effect, :string)
    field(:flavor, :string)
    belongs_to(:expansion, Cardfight.Expansion)
    belongs_to(:type, Cardfight.Type)
    belongs_to(:clan, Cardfight.Clan)
    belongs_to(:race, Cardfight.Race)
    belongs_to(:nation, Cardfight.Nation)
    belongs_to(:skill, Cardfight.Skill)
    belongs_to(:gift, Cardfight.Gift)
    belongs_to(:regulation, Cardfight.Regulation)
    belongs_to(:rarity, Cardfight.Rarity)
    belongs_to(:illustrator, Cardfight.Illustrator)

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required([:number, :name])
    |> unique_constraint(:number)
    |> put_assoc(:expansion, params[:expansion])
    |> put_assoc(:type, params[:type])
    |> put_assoc(:clan, params[:clan])
    |> put_assoc(:race, params[:race])
    |> put_assoc(:nation, params[:nation])
    |> put_assoc(:skill, params[:skill])
    |> put_assoc(:gift, params[:gift])
    |> put_assoc(:regulation, params[:regulation])
    |> put_assoc(:rarity, params[:rarity])
    |> put_assoc(:illustrator, params[:illustrator])
  end

  def assocs, do: @assocs
end
