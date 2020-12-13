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

  def brute_find_mod(base, mult, target_mod, div) do
    case rem(base * mult, div) == target_mod do
      true ->
        base * mult
      _ ->
        brute_find_mod(base, mult + 1, target_mod, div)
    end
  end

  # mod_inverse implementation stolen from https://rosettacode.org/wiki/Modular_inverse#Elixir
  def extended_gcd(a, b) do
    {last_remainder, last_x} = extended_gcd(abs(a), abs(b), 1, 0, 0, 1)
    {last_remainder, last_x * (if a < 0, do: -1, else: 1)}
  end
  defp extended_gcd(last_remainder, 0, last_x, _, _, _), do: {last_remainder, last_x}
  defp extended_gcd(last_remainder, remainder, last_x, x, last_y, y) do
    quotient = div(last_remainder, remainder)
    remainder2 = rem(last_remainder, remainder)
    extended_gcd(remainder, remainder2, x, last_x - quotient*x, y, last_y - quotient*y)
  end
  def mod_inverse(e, et) do
    {g, x} = extended_gcd(e, et)
    if g != 1, do: raise "The maths are broken!"
    rem(x+et, et)
  end

  def find_mod(base, target_mod, div) do
    case target_mod do
      0 ->
        base * div
      _ ->
        base * mod_inverse(base, div) * target_mod
    end
  end

  def reduce_while_larger(s, m) do
    case s < m do
      true -> {s, m}
      false -> reduce_while_larger(s - m, m)
    end
  end

  def calc(rules) do
    sol = Enum.map(rules, fn {inc, rbus} = rule ->
      base = Enum.reduce(rules, 1, fn cand_rule, acc ->
        case cand_rule == rule do
          true ->
            acc
          _ ->
            {_inc, cand_bus} = cand_rule
            acc * cand_bus
        end
      end)
      {base, rem(rbus - inc, rbus), rbus}
    end)
    |> Enum.map(fn {base2, target_mod, bus} ->
      find_mod(base2, target_mod, bus)
    end)
    |> Enum.sum

    mult = Enum.reduce(rules, 1, fn {_, rbus}, acc ->
      acc * rbus
    end)

    reduce_while_larger(sol, mult)
  end

  def run2() do
    rules = full_input |> parse2
    {sol, _} = calc(rules)
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
