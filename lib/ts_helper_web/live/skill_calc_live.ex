defmodule TsHelperWeb.SkillCalcLive do
  use TsHelperWeb, :live_view

  import TsHelperWeb.ErrorHelpers

  @skill_defaults [
    {:hero, 1, 0.4, 0.4},
    {:tool, 0.0, 0.0, 0.3},
    {:companion, 0.0, 0.0, 0.2},
    {:workshop, 0.0, 0.0, 0.1}
  ]

  @skills %{
    hero_trade: 1.0,
    hero_skill: 1.0,
    tool: 0.0,
    companion: 0.0,
    workshop: 0.0,
    magic: 0.0
  }
  @keys [:hero_trade, :hero_skill, :tool, :companion, :workshop, :magic]
  @types Map.new(@keys, &{&1, :float})

  def mount(_params, _args, socket) do
    {:ok,
     assign(socket,
       changeset: changeset(%{}),
       skills: @skill_defaults,
       magic: 0,
       sum: 0
     )}
  end

  def handle_event("change", %{"skills" => skills}, socket) do
    case changeset(skills) do
      %{valid?: true} = cs ->
        data = Ecto.Changeset.apply_changes(cs)

        skills =
          %{
            hero: (data.hero_trade + data.hero_skill) / 2,
            tool: data.tool,
            companion: data.companion,
            workshop: data.workshop
          }
          |> Enum.sort_by(&elem(&1, 1), :asc)
          |> Enum.with_index(1)
          |> Enum.map(fn {{name, value}, idx} -> {name, value, value * idx / 10, idx / 10} end)
          |> Enum.reverse()

        sum = data.magic + (skills |> Enum.map(&elem(&1, 2)) |> Enum.sum())

        {:noreply,
         assign(socket,
           changeset: cs,
           skills: skills,
           magic: data.magic,
           sum: sum
         )}

      cs ->
        {:noreply, assign(socket, changeset: cs, skills: @skill_defaults, sum: 0)}
    end
  end

  defp changeset(data) do
    lower = {:greater_than_or_equal_to, 0}
    upper = {:less_than_or_equal_to, 100}
    message = {:message, "must be between 0 and 100"}

    {@skills, @types}
    |> Ecto.Changeset.cast(data, @keys)
    |> Ecto.Changeset.validate_number(:hero_trade, [lower, upper, message])
    |> Ecto.Changeset.validate_number(:hero_skill, [lower, upper, message])
    |> Ecto.Changeset.validate_number(:tool, [lower, upper, message])
    |> Ecto.Changeset.validate_number(:companion, [lower, upper, message])
    |> Ecto.Changeset.validate_number(:workshop, [lower, upper, message])
    |> Ecto.Changeset.validate_number(:magic, [lower, upper, message])
    |> IO.inspect()
  end
end
