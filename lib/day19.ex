defmodule D19 do

  def run_fsm(m, "a", ["a"]), do: {true, []} # Full match
  def run_fsm(m, "b", ["b"]), do: {true, []} # Full match
  def run_fsm(m, _, []), do: false # Not a full match
  def run_fsm(m, rno, [c|rest] = input) do
    case Map.get(m, rno) do
      char when is_binary(char) ->
        case c == char do
          true ->
            {true, rest}
          false ->
            false
        end
      lol when is_list(lol) ->
        [rule_list] = lol
        Enum.reduce_while(rule_list, {true, input}, fn rule_num, {true, acc} ->
          case run_fsm(m, rule_num, acc) do
            {true, rest} ->
              {:cont, {true, rest}}
            false ->
              {:halt, false}
          end
        end)
    end
  end

  def full_match?(m, input) do
    case run_fsm(m, 0, input) do
      {true, []} -> true
      _ -> false
    end
  end

  def parse_rule(rule) do
    [_, rno, r] = Regex.run(~r/(\d+): ("a"|"b"|[0-9 |]+)/, rule)
    r = case r do
      "\"a\"" ->
        "a"
      "\"b\"" ->
        "b"
      _ ->
        String.split(r, "|")
        |> Enum.map(fn part ->
          String.split(part, " ") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.to_integer/1)
        end)
    end
    {String.to_integer(rno), r}
  end

  def parse_rules_inputs({rules, inputs}) do
    rules = Enum.map(rules, fn rule -> parse_rule(rule) end) |> Enum.into(%{})
    {rules, inputs}
    #run_fsm(rules, 0, Enum.at(inputs, 0))
    #Enum.filter(inputs, fn input -> run_fsm(rules, 0, input) end)
  end

  def test_one do
    {rules, input} =
      """
  0: 4 4 5
  1: 2 3
  2: 4 4
  3: 4 5
  4: "a"
  5: "b"

  aaabbb
  aaaabb
  aabbbb
  """
      |> String.split("\n") |> Enum.split_while(&(&1 != ""))
      {rules, Enum.filter(input, &(&1 != "")) |> Enum.map(&(String.graphemes(&1)))}
    end

  def test_input do
    {rules, input} =
    """
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb
"""
    |> String.split("\n") |> Enum.split_while(&(&1 != ""))
    {rules, Enum.filter(input, &(&1 != ""))}
  end

end
