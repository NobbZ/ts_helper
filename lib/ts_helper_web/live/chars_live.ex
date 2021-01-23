defmodule TsHelperWeb.CharsLive do
  use TsHelperWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    chars = TsHelper.Avatars.list_chars()

    {:ok, assign(socket, chars: chars)}
  end

  @impl true
  def handle_event("delete_click", %{"char-id" => char_id}, socket) do
    socket =
      case socket.assigns.chars |> Enum.find(fn c -> c.id == char_id end) do
        nil ->
          socket
          |> put_flash(:error, "Char not found")
          |> assign(chars: TsHelper.Avatars.list_chars())

        char ->
          case TsHelper.Avatars.delete_char(char) do
            {:ok, _} ->
              socket
              |> put_flash(:info, "Char <em>#{char.name}</em> deleted")
              |> assign(chars: TsHelper.Avatars.list_chars())

            {:error, cs} ->
              socket
              |> put_flash(:error, "#{inspect(cs)}")
          end
      end

    {:noreply, socket}
  end
end
