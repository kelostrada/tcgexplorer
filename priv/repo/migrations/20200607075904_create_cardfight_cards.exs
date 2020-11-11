defmodule Cardfight.Repo.Migrations.CreateCardfightCards do
  use Ecto.Migration

  def change do
    create table(:expansions, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:code, :string)
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:expansions, [:code]))
    create(unique_index(:expansions, [:name]))

    create table(:types, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:types, [:name]))

    create table(:clans, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:clans, [:name]))

    create table(:races, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:races, [:name]))

    create table(:nations, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:nations, [:name]))

    create table(:skills, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:skills, [:name]))

    create table(:gifts, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:gifts, [:name]))

    create table(:regulations, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:regulations, [:name]))

    create table(:rarities, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:rarities, [:name]))

    create table(:illustrators, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      timestamps()
    end

    create(unique_index(:illustrators, [:name]))

    create table(:cards, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:number, :string)
      add(:name, :string)
      add(:image, :string)
      add(:image_small, :string)
      add(:grade, :integer)
      add(:power, :integer)
      add(:critical, :integer)
      add(:shield, :integer)
      add(:effect, :text)
      add(:flavor, :text)

      add(:expansion_id, references(:expansions, type: :uuid))
      add(:type_id, references(:types, type: :uuid))
      add(:clan_id, references(:clans, type: :uuid))
      add(:race_id, references(:races, type: :uuid))
      add(:nation_id, references(:nations, type: :uuid))
      add(:skill_id, references(:skills, type: :uuid))
      add(:gift_id, references(:gifts, type: :uuid))
      add(:regulation_id, references(:regulations, type: :uuid))
      add(:rarity_id, references(:rarities, type: :uuid))
      add(:illustrator_id, references(:illustrators, type: :uuid))

      timestamps()
    end

    create(unique_index(:cards, [:number]))
  end
end
