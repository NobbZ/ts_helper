defmodule TsHelperWeb.TradeLive.Index do
  use TsHelperWeb, :live_view

  alias TsHelper.Skills
  alias TsHelper.Skills.Trade

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :trades, list_trades())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Trade")
    |> assign(:trade, Skills.get_trade!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Trade")
    |> assign(:trade, %Trade{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Trades")
    |> assign(:trade, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    trade = Skills.get_trade!(id)
    {:ok, _} = Skills.delete_trade(trade)

    {:noreply, assign(socket, :trades, list_trades())}
  end

  defp list_trades do
    Skills.list_trades()
  end
end
