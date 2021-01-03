defmodule TsHelperWeb.SkillCalcLive do
  use TsHelperWeb, :live_view

  def render(assigns) do
    ~L"""
    <%= f = form_for :skills, "#", [phx_change: :change, phx_submit: :save] %>
      <%= label f, :hero_trade %>
      <%= text_input f, :hero_trade, value: @hero_trade %>

      <%= label f, :hero_skill %>
      <%= text_input f, :hero_skill, value: @hero_skill %>

      <%= label f, :tool %>
      <%= text_input f, :tool, value: @tool %>

      <%= label f, :companion %>
      <%= text_input f, :companion, value: @companion %>

      <%= label f, :workshop %>
      <%= text_input f, :workshop, value: @workshop %>

      <%= label f, :magic %>
      <%= text_input f, :magic, value: @magic %>
    </form>

    <table>
      <%= for {name, base, value, factor} <- @skills do %>
        <tr>
          <td><%= name %></td>
          <td><%= base %></td>
          <td>×</td>
          <td><%= factor %></td>
          <td>=</td>
          <td><%= value %></td>
        </tr>
      <% end %>
      <tr>
        <td>magic</td>
        <td><%= @magic %></td>
        <td>×</td>
        <td>1.0</td>
        <td>=</td>
        <td><%= @magic %></td>
      </tr>
      <tr>
        <td>sum</td>
        <td></td>
        <td></td>
        <td></td>
        <td>=</td>
        <td><%= @sum %></td>
      </tr>
    </table>
    """
  end

  def mount(params, args, socket) do
    {:ok,
     assign(socket,
       hero_trade: "0",
       hero_skill: "0",
       tool: "0",
       companion: "0",
       workshop: "0",
       magic: "0",
       skills: %{},
       sum: 0
     )}
  end

  def handle_event("change", %{"skills" => skills}, socket) do
    hero_trade = parse(skills["hero_trade"])
    hero_skill = parse(skills["hero_skill"])
    tool = parse(skills["tool"])
    companion = parse(skills["companion"])
    workshop = parse(skills["workshop"])
    magic = parse(skills["magic"])

    skills =
      %{
        hero: (hero_trade + hero_skill) / 2,
        tool: tool,
        companion: companion,
        workshop: workshop
      }
      |> Enum.sort_by(&elem(&1, 1), :asc)
      |> Enum.with_index(1)
      |> Enum.map(fn {{name, value}, idx} -> {name, value, value * idx / 10, idx / 10} end)
      |> Enum.reverse()

    sum = magic + (skills |> Enum.map(&elem(&1, 2)) |> Enum.sum())

    {:noreply,
     assign(socket,
       hero_trade: hero_trade,
       hero_skill: hero_skill,
       magic: magic,
       tool: tool,
       companion: companion,
       workshop: workshop,
       skills: skills,
       sum: sum
     )}
  end

  defp parse(""), do: 0

  defp parse(data) do
    case Integer.parse(data) do
      {n, ""} -> n
      {_, "." <> _} -> String.to_float(data <> "0")
    end
  end
end
