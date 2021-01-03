defmodule TsHelperWeb.SkillCalcLive do
  use TsHelperWeb, :live_view

  @skill_defaults [
    {:hero, 1, 0.4, 0.4},
    {:tool, 0.0, 0.0, 0.3},
    {:companion, 0.0, 0.0, 0.2},
    {:workshop, 0.0, 0.0, 0.1}
  ]

  def mount(_params, _args, socket) do
    {:ok,
     assign(socket,
       hero_trade: "1",
       hero_skill: "1",
       tool: "0",
       companion: "0",
       workshop: "0",
       magic: "0",
       skills: @skill_defaults,
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
