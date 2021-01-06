defmodule TsHelperWeb.CharsLive do
  use TsHelperWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    chars = TsHelper.Avatars.list_chars()

    {:ok, assign(socket, chars: chars)}
  end

  @impl true
  def handle_event("delete_click", %{"char-id" => char_id}, socket) do
    {:noreply, socket}
  end
end
