defmodule TcgExplorerWeb.BrowserLive do
  use TcgExplorerWeb, :live_view
  alias Cardfight.Cache
  alias TcgExplorerWeb.Router.Helpers, as: Routes
  import Ecto.Changeset

  defmodule FilterForm do
    use Ecto.Schema
    import Ecto.Changeset

    @fields ~w(query keyword grade expansion type clan race nation
    skill gift regulation rarity illustrator)a

    embedded_schema do
      field :query, :string
      field :keyword, :string
      field :grade, :integer

      field :expansion, :string
      field :type, :string
      field :clan, :string
      field :race, :string
      field :nation, :string
      field :skill, :string
      field :gift, :string
      field :regulation, :string
      field :rarity, :string
      field :illustrator, :string
    end

    def changeset(params \\ %{})

    def changeset(nil), do: changeset()

    def changeset(params) do
      %FilterForm{}
      |> cast(params, @fields)
    end
  end

  @impl true
  def mount(%{"game" => game}, _session, socket) do
    db = Cache.get_all()

    filters = %{
      grades: [{"ANY", nil}] ++ db.grades,
      expansions: [{"ANY", nil}] ++ Enum.map(db.expansions, &{"#{&1.code}: #{&1.name}", &1.code}),
      types: [{"ANY", nil}] ++ Enum.map(db.types, & &1.name),
      clans: [{"ANY", nil}] ++ Enum.map(db.clans, & &1.name),
      races: [{"ANY", nil}] ++ Enum.map(db.races, & &1.name),
      nations: [{"ANY", nil}] ++ Enum.map(db.nations, & &1.name),
      skills: [{"ANY", nil}] ++ Enum.map(db.skills, & &1.name),
      gifts: [{"ANY", nil}] ++ Enum.map(db.gifts, & &1.name),
      regulations: [{"ANY", nil}] ++ Enum.map(db.regulations, & &1.name),
      rarities: [{"ANY", nil}] ++ Enum.map(db.rarities, & &1.name),
      illustrators: Enum.map(db.illustrators, & &1.name)
    }

    {:ok,
     socket
     |> assign(card: nil)
     |> assign(filters: filters)
     |> assign(more_filters: false)
     |> assign(game: game)
     |> assign(page_title: "#{String.capitalize(game)} Browser")
     |> fetch(%{})}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    send(self(), {:fetch, params})
    {:noreply, assign(socket, params: params, page: %{socket.assigns.page | entries: :loading})}
  end

  @impl true
  def handle_info({:fetch, params}, socket) do
    {:noreply, fetch(socket, params)}
  end

  @impl true
  def handle_event("filter_change", params, socket) do
    {:noreply, push_patch(socket, to: Routes.browser_path(socket, :game, :cardfight, params))}
  end

  def handle_event("page", %{"page" => page}, socket) do
    params = socket.assigns.params
    params = Map.put(params, "page", page)
    {:noreply, push_patch(socket, to: Routes.browser_path(socket, :game, :cardfight, params))}
  end

  def handle_event("card_details", %{"card-id" => id}, %{assigns: %{card: %{id: id}}} = socket) do
    {:noreply, assign(socket, card: nil)}
  end

  def handle_event("card_details", %{"card-id" => card_id}, socket) do
    card = Enum.find(socket.assigns.page.entries, &(&1.id == card_id))
    {:noreply, assign(socket, card: card)}
  end

  def handle_event("close_details", _, socket) do
    {:noreply, assign(socket, card: nil)}
  end

  def handle_event("reset_filters", _, socket) do
    socket = fetch(socket, %{})

    {:noreply,
     push_patch(socket, to: Routes.browser_path(socket, :game, :cardfight, socket.assigns.params))}
  end

  def handle_event("display_more_filters", _, socket) do
    {:noreply, assign(socket, more_filters: true)}
  end

  def handle_event("hide_more_filters", _, socket) do
    {:noreply, assign(socket, more_filters: false)}
  end

  defp fetch(socket, params) do
    params = Map.put(params, "page_size", 16)
    changeset = FilterForm.changeset(params["filter_form"])
    db = Cache.get_all()

    page =
      db.cards
      |> filter_by(changeset)
      |> Scrivener.paginate(params)

    assign(socket, page: page, changeset: changeset, params: params)
  end

  def filter_by(cards, form) do
    filters =
      form
      |> apply_changes()
      |> Map.from_struct()
      |> Map.delete(:__meta__)

    Enum.reduce(filters, cards, fn {key, value}, cards ->
      update_list(cards, key, value, filters)
    end)
  end

  def update_list(list, _, nil, _), do: list

  def update_list(list, :query, value, _) do
    value = String.downcase(value)

    Enum.filter(list, fn card ->
      (card.name != nil && card.name |> String.downcase() |> String.contains?(value)) ||
        (card.number != nil && card.number |> String.downcase() |> String.contains?(value))
    end)
  end

  def update_list(list, :keyword, value, _) do
    value = String.downcase(value)

    Enum.filter(list, fn card ->
      card.effect != nil && card.effect |> String.downcase() |> String.contains?(value)
    end)
  end

  def update_list(list, :grade, value, _) do
    Enum.filter(list, fn card -> card.grade == value end)
  end

  def update_list(list, :expansion, value, _) do
    Enum.filter(list, fn card -> card.expansion != nil && card.expansion.code == value end)
  end

  def update_list(list, :regulation, value, _) do
    Enum.filter(list, fn card -> card.regulation != nil && card.regulation.name == value end)
  end

  def update_list(list, :rarity, value, _) do
    Enum.filter(list, fn card -> card.rarity != nil && card.rarity.name == value end)
  end

  def update_list(list, :type, value, _) do
    Enum.filter(list, fn card -> card.type != nil && card.type.name == value end)
  end

  def update_list(list, :clan, value, _) do
    Enum.filter(list, fn card -> card.clan != nil && card.clan.name == value end)
  end

  def update_list(list, :race, value, _) do
    Enum.filter(list, fn card -> card.race != nil && card.race.name == value end)
  end

  def update_list(list, :nation, value, _) do
    Enum.filter(list, fn card -> card.nation != nil && card.nation.name == value end)
  end

  def update_list(list, :skill, value, _) do
    Enum.filter(list, fn card -> card.skill != nil && card.skill.name == value end)
  end

  def update_list(list, :gift, value, _) do
    Enum.filter(list, fn card -> card.gift != nil && card.gift.name == value end)
  end

  def update_list(list, :illustrator, value, _) do
    value = String.downcase(value)

    Enum.filter(list, fn card ->
      card.illustrator != nil && String.downcase(card.illustrator.name) == value
    end)
  end

  def name(nil), do: "-"
  def name(entity), do: entity.name
end
