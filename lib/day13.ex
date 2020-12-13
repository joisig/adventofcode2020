defmodule Day13 do

  def run1 do
    {ts, buses} = full_input
    {depart, bus} = Enum.map(buses, fn bus -> {div(ts, bus) * bus + bus, bus} end)
    |> Enum.sort_by(fn {depart, _} -> depart end)
    |> Enum.at(0)
    (depart - ts) * bus
  end

  def test_input do
    lines = """
939
7,13,x,x,59,x,31,19
"""
    |> String.split("\n")
    {
      Enum.at(lines, 0) |> String.to_integer,
      Enum.at(lines, 1) |> String.split(",") |> Enum.filter(&(&1 != "x")) |> Enum.map(&String.to_integer/1)
    }
  end

  def full_input do
    lines = """
1001287
13,x,x,x,x,x,x,37,x,x,x,x,x,461,x,x,x,x,x,x,x,x,x,x,x,x,x,17,x,x,x,x,19,x,x,x,x,x,x,x,x,x,29,x,739,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,x,x,x,23
"""
    |> String.split("\n")
    {
      Enum.at(lines, 0) |> String.to_integer,
      Enum.at(lines, 1) |> String.split(",") |> Enum.filter(&(&1 != "x")) |> Enum.map(&String.to_integer/1)
    }
  end

end
