defmodule TsHelperWeb.CharsLive do
  use TsHelperWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    chars = TsHelper.Avatars.list_chars()

    {:ok, assign(socket, chars: chars)}
  end
end
