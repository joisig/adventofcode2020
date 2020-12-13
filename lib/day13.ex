defmodule Day13 do

  def run1 do
    {ts, buses} = full_input |> parse1
    {depart, bus} = Enum.map(buses, fn bus -> {div(ts, bus) * bus + bus, bus} end)
    |> Enum.sort_by(fn {depart, _} -> depart end)
    |> Enum.at(0)
    (depart - ts) * bus
  end

  def parse1(lines) do
    {
      Enum.at(lines, 0) |> String.to_integer,
      Enum.at(lines, 1) |> String.split(",") |> Enum.filter(&(&1 != "x")) |> Enum.map(&String.to_integer/1)
    }
  end

  def parse2(lines) do
    Enum.at(lines, 1) |> String.split(",") |> Enum.reduce({0, []}, fn it, {index, list} ->
      case it do
        "x" -> {index + 1, list}
        _ -> {index + 1, list ++ [{index, String.to_integer(it)}]}
      end
    end)
    |> elem(1)
  end

  def brute_test(t, []), do: true
  def brute_test(t, [{inc, rule}|rest]) do
    case rem(t + inc, rule) do
      0 -> brute_test(t, rest)
      _ -> false
    end
  end

  def brute_find(t, incr, rules) do
    case brute_test(t, rules) do
      true -> t
      _ -> brute_find(t + incr, incr, rules)
    end
  end

  def run2_brute() do
    rules = full_input |> parse2
    {inc, bus} = Enum.sort_by(rules, fn {inc, bus} -> bus end) |> Enum.at(-1)
    brute_find(bus - inc, bus, rules)
  end

  def test_input do
    lines = """
939
7,13,x,x,59,x,31,19
"""
    |> String.split("\n")
  end

  def full_input do
    lines = """
1001287
13,x,x,x,x,x,x,37,x,x,x,x,x,461,x,x,x,x,x,x,x,x,x,x,x,x,x,17,x,x,x,x,19,x,x,x,x,x,x,x,x,x,29,x,739,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,x,x,x,23
"""
    |> String.split("\n")
  end

end
