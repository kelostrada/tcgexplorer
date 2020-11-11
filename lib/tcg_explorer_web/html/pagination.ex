defmodule TcgExplorerWeb.HTML.Pagination do
  use Phoenix.HTML

  @moduledoc false
  @defaults [action: :index, page_param: :page]

  def pagination(paginator, opts \\ []) do
    if paginator.total_pages > 1 do
      Scrivener.HTML.pagination_links(paginator, opts)
    end
  end

  def pagination(conn, paginator, opts) do
    if paginator.total_pages > 1 do
      Scrivener.HTML.pagination_links(conn, paginator, opts)
    end
  end

  def live_pagination(paginator, opts \\ []) do
    if paginator.total_pages > 1 do
      params = Keyword.drop(opts, Keyword.keys(@defaults) ++ [:path])

      content_tag :ul, class: "pagination" do
        paginator
        |> Scrivener.HTML.raw_pagination_links(params)
        |> Enum.map(&page(&1, paginator))
      end
    end
  end

  defp page({:ellipsis, text}, paginator) do
    content_tag(:li) do
      content_tag(:span, safe(text), class: link_classes(paginator, :ellipsis))
    end
  end

  defp page({text, page_number}, paginator) do
    content_tag :li do
      if active_page?(paginator, page_number) do
        content_tag(:a, safe(text), class: link_classes(paginator, page_number))
      else
        content_tag(:a, safe(text),
          phx_click: :page,
          phx_value_page: page_number,
          class: link_classes(paginator, page_number)
        )
      end
    end
  end

  defp active_page?(%{page_number: page_number}, page_number), do: true
  defp active_page?(_paginator, _page_number), do: false

  defp link_classes(_paginator, :ellipsis), do: "pagination-ellipsis"

  defp link_classes(paginator, page_number) do
    if paginator.page_number == page_number,
      do: "pagination-link active",
      else: "pagination-link"
  end

  defp safe({:safe, _string} = whole_string) do
    whole_string
  end

  defp safe(string) when is_binary(string) do
    string
  end

  defp safe(string) do
    string
    |> to_string()
    |> raw()
  end
end
