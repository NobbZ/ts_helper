# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TsHelper.Repo.insert!(%TsHelper.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TsHelper.Repo

Enum.each(~W[Other], &Repo.insert!("trades", name: &1))
