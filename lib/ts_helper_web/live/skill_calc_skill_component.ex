defmodule TsHelperWeb.SkillCalcSkillComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <tr>
      <td><%= display(@name) %></td>
      <td><%= @base %></td>
      <td>×</td>
      <td><%= @mod %></td>
      <td>=</td>
      <td><%= @real %></td>
    </tr>
    """
  end

  defp display(:hero), do: "Hero"
  defp display(:tool), do: "Tool"
  defp display(:companion), do: "Companion"
  defp display(:workshop), do: "Workshop"
  defp display(:magic), do: "Magic"
end
