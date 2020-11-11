defmodule Cardfight.Cache do
  use GenServer

  alias TcgExplorer.Repo

  alias Cardfight.{
    Card,
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

  import Ecto.Query

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    send(self(), :fetch_cards)
    {:ok, %{cards: []}}
  end

  def refresh() do
    send(__MODULE__, :fetch_cards)
  end

  def get_all() do
    GenServer.call(__MODULE__, :get_all)
  end

  def handle_info(:fetch_cards, _state) do
    {:noreply,
     %{
       cards: get_all_cards(),
       grades: get_all_grades(),
       expansions: get_all_expansions(),
       types: get_all_types(),
       clans: get_all_clans(),
       races: get_all_races(),
       nations: get_all_nations(),
       skills: get_all_skills(),
       gifts: get_all_gifts(),
       regulations: get_all_regulations(),
       rarities: get_all_rarities(),
       illustrators: get_all_illustrators()
     }}
  end

  def handle_call(:get_all, _from, state) do
    {:reply, state, state}
  end

  defp get_all_cards() do
    Card
    |> select_joins()
    |> order_by([c], desc: c.number)
    |> Repo.all()
  end

  defp get_all_expansions() do
    Expansion
    |> order_by([e], asc: e.code)
    |> Repo.all()
  end

  defp get_all_types() do
    Type
    |> order_by([t], asc: t.name)
    |> Repo.all()
  end

  defp get_all_clans() do
    Clan
    |> order_by([c], asc: c.name)
    |> Repo.all()
  end

  defp get_all_races() do
    Race
    |> order_by([r], asc: r.name)
    |> Repo.all()
  end

  defp get_all_nations() do
    Nation
    |> order_by([n], asc: n.name)
    |> Repo.all()
  end

  defp get_all_skills() do
    Skill
    |> order_by([s], asc: s.name)
    |> Repo.all()
  end

  defp get_all_gifts() do
    Gift
    |> order_by([g], asc: g.name)
    |> Repo.all()
  end

  defp get_all_regulations() do
    Regulation
    |> order_by([r], asc: r.name)
    |> Repo.all()
  end

  defp get_all_rarities() do
    Rarity
    |> order_by([r], asc: r.name)
    |> Repo.all()
  end

  defp get_all_illustrators() do
    Illustrator
    |> order_by([i], asc: i.name)
    |> Repo.all()
  end

  defp get_all_grades() do
    Repo.all(
      from c in Card,
        group_by: c.grade,
        select: c.grade,
        order_by: c.grade
    )
  end

  defp select_joins(query) do
    query
    |> join(:left, [c], e in Expansion, on: e.id == c.expansion_id)
    |> join(:left, [c], t in Type, on: t.id == c.type_id)
    |> join(:left, [c], clan in Clan, on: clan.id == c.clan_id)
    |> join(:left, [c], r in Race, on: r.id == c.race_id)
    |> join(:left, [c], n in Nation, on: n.id == c.nation_id)
    |> join(:left, [c], s in Skill, on: s.id == c.skill_id)
    |> join(:left, [c], g in Gift, on: g.id == c.gift_id)
    |> join(:left, [c], r in Regulation, on: r.id == c.regulation_id)
    |> join(:left, [c], r in Rarity, on: r.id == c.rarity_id)
    |> join(:left, [c], i in Illustrator, on: i.id == c.illustrator_id)
    |> preload([c, e, t, cl, r, n, s, g, re, ra, i],
      expansion: e,
      type: t,
      clan: cl,
      race: r,
      nation: n,
      skill: s,
      gift: g,
      regulation: re,
      rarity: ra,
      illustrator: i
    )
  end
end
