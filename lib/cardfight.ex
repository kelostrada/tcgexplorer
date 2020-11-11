defmodule Cardfight do
  @moduledoc """
  Documentation for `Cardfight`.
  """
  alias TcgExplorer.Repo

  alias Cardfight.{
    Card,
    Parser,
    Clan,
    Expansion,
    Gift,
    Illustrator,
    Nation,
    Race,
    Rarity,
    Regulation,
    Skill,
    Type
  }

  @card_address "https://en.cf-vanguard.com/cardlist/?cardno="
  @page_address "https://en.cf-vanguard.com/cardlist/cardsearch_ex/?regulation%5B0%5D=V&keyword=&keyword_type%5B0%5D=all&clan=&kind%5B0%5D=all&grade%5B0%5D=all&power_from=&power_to=&rare=&trigger%5B0%5D=all&page="
  @expansion_address "https://en.cf-vanguard.com/cardlist/cardsearch_ex/?expansion=:expansion&page=:page"

  def fetch_expansion(expansion, page) do
    {:ok, response} =
      @expansion_address
      |> String.replace(":expansion", to_string(expansion))
      |> String.replace(":page", to_string(page))
      |> Tesla.get()

    response.body
    |> Parser.parse_page()
    |> Enum.map(fn code ->
      code |> fetch_card() |> insert_card()
    end)
  end

  def fetch_page(page) do
    {:ok, response} = Tesla.get(@page_address <> to_string(page))

    response.body
    |> Parser.parse_page()
    |> Enum.map(fn code ->
      code |> fetch_card() |> insert_card()
    end)
  end

  @doc """
  Hello world.
  """
  def fetch_card(number) do
    {:ok, response} = Tesla.get(@card_address <> URI.encode(number))
    document = Parser.parse(response.body)

    expansion = Parser.expansion(document)

    %{
      number: Parser.number(document),
      name: Parser.name(document),
      image_small: Parser.image(document),
      grade: Parser.grade(document),
      power: Parser.power(document),
      critical: Parser.critical(document),
      shield: Parser.shield(document),
      effect: Parser.effect(document),
      flavor: Parser.flavor(document),
      expansion: %{name: expansion["name"], code: expansion["code"]},
      type: %{name: Parser.type(document)},
      clan: %{name: Parser.clan(document)},
      race: %{name: Parser.race(document)},
      nation: %{name: Parser.nation(document)},
      skill: %{name: Parser.skill(document)},
      gift: %{name: Parser.gift(document)},
      regulation: %{name: Parser.regulation(document)},
      rarity: %{name: Parser.rarity(document)},
      illustrator: %{name: Parser.illustrator(document)}
    }
    |> Map.update!(:expansion, &update_field(&1, Expansion, :code))
    |> Map.update!(:type, &update_field(&1, Type))
    |> Map.update!(:clan, &update_field(&1, Clan))
    |> Map.update!(:race, &update_field(&1, Race))
    |> Map.update!(:nation, &update_field(&1, Nation))
    |> Map.update!(:skill, &update_field(&1, Skill))
    |> Map.update!(:gift, &update_field(&1, Gift))
    |> Map.update!(:regulation, &update_field(&1, Regulation))
    |> Map.update!(:rarity, &update_field(&1, Rarity))
    |> Map.update!(:illustrator, &update_field(&1, Illustrator))
  end

  def insert_card(card_data) do
    case Repo.get_by(Card, number: card_data.number) do
      nil -> %Card{}
      card -> Repo.preload(card, Card.assocs())
    end
    |> Card.changeset(card_data)
    |> Repo.insert_or_update()
  end

  defp update_field(map, schema, key \\ :name) do
    value = Map.get(map, key)

    if value && value != "" do
      case Repo.get_by(schema, %{key => value}) do
        nil -> map
        entity -> schema.changeset(entity, map)
      end
    end
  end
end
