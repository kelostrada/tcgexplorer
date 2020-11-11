defmodule Cardfight.Parser do
  def parse_page(body) do
    {:ok, document} = Floki.parse_document(body)

    document
    |> Floki.find("li.ex-item a")
    |> Enum.map(&Floki.attribute(&1, "href"))
    |> Enum.map(fn [uri | _] ->
      uri
      |> URI.parse()
      |> Map.get(:query)
      |> URI.query_decoder()
      |> Enum.to_list()
      |> Map.new()
      |> Map.get("cardno")
    end)
  end

  def parse(body) do
    {:ok, document} = Floki.parse_document(body)
    Floki.find(document, "div.inner-content")
  end

  def number(document), do: find(document, "div.number")
  def name(document), do: find(document, "div.name span.face")

  def image(document) do
    document
    |> Floki.find("div.image div.main img")
    |> Floki.attribute("src")
    |> List.first()
  end

  def grade(document) do
    document
    |> find("div.grade")
    |> parse_labeled_int()
  end

  def power(document) do
    document
    |> find("div.power")
    |> parse_labeled_int()
  end

  def critical(document) do
    document
    |> find("div.critical")
    |> parse_labeled_int(1)
  end

  def shield(document) do
    document
    |> find("div.shield")
    |> parse_labeled_int()
  end

  def effect(document), do: find(document, "div.effect")
  def flavor(document), do: find(document, "div.flavor")

  def type(document), do: find(document, "div.type")
  def clan(document), do: find(document, "div.group")
  def race(document), do: find(document, "div.race")
  def nation(document), do: find(document, "div.nation")

  def skill(document), do: find(document, "div.skill")
  def gift(document), do: find(document, "div.gift")

  def regulation(document), do: find(document, "div.regulation")
  def rarity(document), do: find(document, "div.rarity")
  def illustrator(document), do: find(document, "div.illstrator")

  def expansion(document) do
    expansion = find(document, "h3.style-h3")

    ~r/(\[(?<code>.*)\])?(?<name>.*)/
    |> Regex.named_captures(expansion)
    |> default_to(%{})
    |> Enum.map(fn {key, value} -> {key, String.trim(value)} end)
    |> Enum.into(%{})
  end

  def find(document, what) do
    document
    |> Floki.find(what)
    |> Floki.text()
    |> String.trim()
  end

  @int_regex ~r/[0-9]+/

  defp parse_labeled_int(label, default \\ 0) do
    @int_regex
    |> Regex.run(label)
    |> list_to_integer(default)
  end

  defp list_to_integer(nil, default), do: default

  defp list_to_integer(list, _default) do
    list
    |> List.first()
    |> String.to_integer()
  end

  def default_to(nil, default), do: default
  def default_to(any, _default), do: any
end
