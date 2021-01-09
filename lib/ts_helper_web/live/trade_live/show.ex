defmodule TsHelperWeb.TradeLive.Show do
  use TsHelperWeb, :live_view

  alias TsHelper.Skills

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:trade, Skills.get_trade!(id))}
  end

  defp page_title(:show), do: "Show Trade"
  defp page_title(:edit), do: "Edit Trade"
end
