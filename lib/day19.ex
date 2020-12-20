defmodule D19 do

  def run_fsm(m, rno, []) do # Not a full match
    false
  end
  def run_fsm(m, rno, [c|rest] = input) do
    case Map.get(m, rno) do
      char when is_binary(char) ->
        case c == char do
          true ->
            {true, rest}
          _ ->
            false
        end
      lol when is_list(lol) ->
        val = Enum.find_value(lol, fn rule_list ->
          ival = Enum.reduce_while(rule_list, {true, input}, fn rule_num, {true, acc} ->
            case run_fsm(m, rule_num, acc) do
              {true, rest} ->
                {:cont, {true, rest}}
              _ ->
                {:halt, false}
            end
          end)
          ival
        end)
        val
    end
  end

  def full_match?(m, input) do
    run_fsm(m, 0, input) == {true, []}
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
  end

  def run1 do
    {rules, inputs} = full_input |> parse_rules_inputs
    Enum.count(inputs, fn input -> full_match?(rules, input) end)
  end

  def multiply_rule(rule, times_to_mult) do
    Enum.map(1..times_to_mult, fn _ ->
      rule
    end)
  end

  def multiply_mid_rule_impl(_, _, 0), do: []
  def multiply_mid_rule_impl(left, right, times_to_mult) do
    [left, multiply_mid_rule_impl(left, right, times_to_mult - 1), right]
  end

  def multiply_mid_rule(left, right, num_rules) do
    multiply_mid_rule_impl(left, right, num_rules) |> List.flatten
  end

  def run2 do
    {rules, inputs} = full_input |> parse_rules_inputs

    # The new looping rules are self-referential. The inputs to check are limited to
    # about 70 or 80 in length, so we just unroll the first X loops.

    # We need to run once for each unrolled version of the rules. There are two so
    # each length X each length.

    Enum.reduce(1..20, [], fn x, acc ->
      Enum.reduce(1..20, acc, fn y, acc ->
        [[rule_8]] = Map.get(rules, 8)
        rule_8 = [multiply_rule(rule_8, x)]
        [[left, right]] = Map.get(rules, 11)
        rule_11 = [multiply_mid_rule(left, right, y)]
        mod_rules = Map.put(rules, 8, rule_8) |> Map.put(11, rule_11)
        Enum.filter(inputs, fn input -> full_match?(mod_rules, input) end) ++ acc
      end)
    end)
    |> Enum.uniq
    |> Enum.map(fn gl -> Enum.join(gl, "") end)
    |> length
  end

  def test_two do
    {rules, input} =
      """
0: 1
1: 2
2: 3
3: 4
4: "a"
5: "b"

aaabbb
a
aabbbb
"""
      |> String.split("\n") |> Enum.split_while(&(&1 != ""))
      {rules, Enum.filter(input, &(&1 != "")) |> Enum.map(&(String.graphemes(&1)))}
    end

  def test_one do
    {rules, input} =
      """
0: 4 4 5 | 4 4 5 5 | 4 5 4 5
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
    {rules, Enum.filter(input, &(&1 != "")) |> Enum.map(&(String.graphemes(&1)))}
  end

  def full_input do
    {rules, input} =
    """
90: 86 86
122: 86 1 | 99 20
116: 86 58 | 99 75
20: 86 123
62: 99 95 | 86 113
81: 76 99 | 90 86
106: 120 86 | 93 99
73: 99 72 | 86 45
117: 131 99 | 72 86
92: 86 96 | 99 98
13: 3 99 | 118 86
56: 90 86 | 58 99
85: 72 99 | 51 86
51: 99 99 | 86 86
59: 99 25 | 86 62
65: 99 15 | 86 97
112: 86 13 | 99 38
46: 33 86 | 2 99
10: 67 86 | 68 99
33: 120 99 | 76 86
38: 35 86 | 125 99
26: 86 10 | 99 55
1: 33 99 | 60 86
8: 42
16: 51 86 | 93 99
107: 40 99 | 2 86
40: 17 120
34: 86 82 | 99 127
88: 93 17
2: 99 51 | 86 120
32: 100 99 | 7 86
113: 86 127 | 99 82
14: 73 86 | 44 99
25: 86 101 | 99 56
130: 110 86 | 109 99
19: 86 4 | 99 49
30: 86 92 | 99 70
27: 17 86 | 86 99
94: 47 86 | 53 99
115: 86 107 | 99 84
15: 76 99 | 58 86
58: 86 99
105: 130 86 | 32 99
71: 120 99 | 131 86
12: 99 131 | 86 82
60: 72 86 | 93 99
84: 86 102 | 99 80
44: 99 76 | 86 72
125: 76 99 | 131 86
18: 99 71 | 86 52
129: 37 86 | 111 99
102: 99 131 | 86 76
66: 86 105 | 99 41
99: "a"
9: 99 18 | 86 65
131: 17 99 | 99 86
39: 76 99 | 93 86
64: 115 99 | 114 86
57: 86 48 | 99 94
35: 72 86 | 51 99
0: 8 11
77: 86 83 | 99 106
118: 72 86 | 75 99
47: 99 103 | 86 85
23: 99 27 | 86 76
48: 119 99 | 78 86
49: 86 51 | 99 45
67: 86 120
61: 86 72 | 99 127
108: 72 99 | 72 86
95: 86 58 | 99 90
83: 86 27 | 99 131
75: 86 99 | 99 99
101: 51 99 | 27 86
103: 90 99 | 90 86
128: 86 69 | 99 33
70: 99 14 | 86 19
52: 127 86 | 90 99
21: 86 24 | 99 59
22: 86 63 | 99 12
42: 79 86 | 66 99
97: 51 17
104: 86 33 | 99 28
100: 99 16 | 86 39
72: 99 86
78: 86 43 | 99 50
55: 86 6 | 99 34
45: 99 99
5: 86 46 | 99 77
93: 99 99 | 99 86
6: 131 99 | 51 86
110: 71 86 | 28 99
68: 90 86 | 27 99
29: 87 86 | 122 99
80: 86 93 | 99 131
54: 120 86 | 75 99
43: 93 86
98: 99 103 | 86 117
7: 101 86 | 88 99
127: 17 86 | 99 99
96: 86 12 | 99 61
41: 99 5 | 86 112
79: 86 57 | 99 21
11: 42 31
86: "b"
111: 45 99 | 72 86
63: 76 99 | 127 86
124: 86 81 | 99 116
28: 86 75 | 99 58
82: 99 86 | 86 99
121: 64 86 | 74 99
87: 86 124 | 99 104
74: 99 26 | 86 9
31: 126 99 | 121 86
50: 99 72
119: 34 86 | 36 99
36: 86 82 | 99 75
91: 86 131
3: 58 99 | 27 86
114: 99 129 | 86 22
24: 86 89 | 99 128
53: 91 99 | 95 86
126: 29 86 | 30 99
109: 99 108 | 86 23
17: 86 | 99
76: 86 86 | 99 86
120: 17 17
89: 54 86 | 37 99
4: 99 131 | 86 58
69: 27 17
37: 99 58
123: 86 76 | 99 82

bbababbaabbaaabaaaabbabbbbbababbbababaaaabbaabaaaaaabaaaabbaabba
aaabbbabbabbbbbbaabbabababaaaaabaaabaaaaabaaaabbbbabbabb
babaabaabbabaaaaabbababb
babbabbaababbaaaababbaabbbbbaabaabbbababaabbbabbbabababaabbabbabaabbbaababbbbbbb
bababbbabaaabbaabbababab
aaaaabaaaabbaabaaaaabbaa
aabbbaaaaababbaaabaabbbbabbbaaaaabbaaaab
baaaabaaaabbababbaaabbab
ababababaaaaabaaaaabbaaa
baabaababaaabbaabbbababb
abbbabbbbbabaaabaabbabbb
aaababbbabababbbaabbaaaabababbaa
babbaaabbaaaabaababbbabb
bbbabbbabbabaaaabaabaaab
bbbbaaabaaaabbbaabbbbabb
aaaaaaaaaaaaabaabaaaabbb
babaabbababbabaababbaaba
bbabaaaabaaabbaaaabbbbbbbabbabbbbaaaabab
babaabbbbbbbbbaabbaaabaa
baabbbabababbababaabbbaa
baaaabaaaabaaaaaaaaaaaab
aaabbbbbbbabbbabbbbbabbb
bbabaaabaaababaabbbbbbba
baaabaaabbabbaaaaaaababb
abbabaabbaaaaaaaaabaabba
aaaabababbbbbbaabababbab
bbbbbbabababbaabaabbbabaaaabbabbaabbabbbbaababbbabaabbbbabbabaabababaabaaaaaabab
bbbabbaaaababbabaabaabbbabbbabab
bbbabbbababbbbaabbbbbbab
baabaaaaabaabbbbaaabaaaabbbbbbab
bbbbaaaaaabaaaaaabbbabaababbaabb
bbbbbabaabaaaaababbaaabbbaababbbbbaaabaa
aaabaabaaaabaaaaababbaaaaaababbbaaababab
bbaaaababbbaaabbabbabbabbabbbbabbababaabbbabbabbabaaabbabaaaabba
aababbbaaaabbbaabbbbababbabbaaaa
abbbaabbabaaaaababaaaaaa
babbabbabbaabababbabaaaaaabbbabbbabaabbbbabbbaabbaaaaaba
aabbbaabaaabbabbbbaabaaabbbabbababbaababababbbba
baabbabbbaabbbbbbbaaaaaababababaaabbbbabaabaabbaaaaabbab
bbabaaabbbbbaaaababbabbb
baabaabaaababbbabaaababa
aaaabbbbabbbaabbababaaaa
babbababaaaababababaabab
bbbaabbbabbbabaabbbabbbaaabbaabbabbbbbbbaaaabaaabaaabbaabbbbabbb
aabbaabbabbabbbabaaaabba
abaabbaaaaabbabbaaabbbabbabbaaaa
bababaabbaaabaaababbababbbbbbabbbaaabaab
aaababbbaabbaabbbbaaabbaaababaaabaabbbaa
abbaaababbaaababbaaaabba
bbaababaaabbabaaababbaabbaabbbbaaabbaabbabaaabbabbabbbbbabbbaaabbbababbb
bbaaabbbbbaaabbabaaaabba
abbbabaabbaabaaaaaabbaaa
bbbabaabbbbbbbaababbbbaaabbbabba
abbabbaaaaaabbbbbbabaaabbaaaaaab
bbaababaaaababaabaabbababbbbbaab
aabbababaaabbbaaaaabbabbaabbbbbbbabbbabb
aaabbbaaaababbabbababbbb
aababbababaaabaabababbbb
bbabbbabbbabbbabababbbba
aaabaaaaabbbbbbbbaaaaaab
babaabbbaaabbbabbaaaaaab
bbaabbbaaabbababbbaaabaa
aabbbaaaaaaaaaaaaaaaabaaaabbbbbabbabaaaaabbbbbab
abaaaaabaabbbaaaabbbaaab
abaabbabbabbbbbabbababaa
baaabbaaaabbbabbaaaabaaa
abbbbbaabbaaababbbbabaab
aababbaaaabbbbbabaababaabababaabbabbbaba
abaabaaabbabababababababbaabaaabbbaabaabaabbbababbbabbbabbabbbbbabababaabbabbaba
aaaaaabaaaaabababbbabbabbbaabbabaababbbb
babaaaababaaababaabbabba
ababbaaaabaaabbbbababaaa
baababbbabbbbaaabaababbbabbbbaababaaabaaaabbaabababababaaaaababa
bbaabbababbabaabbbabbabb
bbabbbbaababbaabbbbabbbbbabbabaaaaabbbababbbbaabaaaaaabbbababbbbbabbbabb
baaaaaaababaaaabbbbbaaaaabaabbbbbaababbb
aabbabaaabbbbbaabbbaabab
ababbabbbbaabaaabababaabaaaabbab
aaabbabaaaaabbbbabbbbaaa
bbaaaaabbaaaabaaabbbaaaa
abbbaaaaabbbabbbabbabaaa
bbaaaabbaaaababababaababaaaabbbaaabaabaaaababbabbbaaaabaabaaabbaababbbaaabaabbaababbbaabaabaabbb
bbaabbaaaababbababbaaabbbabbbababbbbbbaabbaabababbababaababbaababbbaaabbaabbbbab
aababbabaaabaaaabbaabbaa
babaaabbaaabaababbabbbbabbbaabaabbaabbbababbabaabababaabbbababbabbbbaababbaabaaa
baabbabbbbaabbbaaabbaaab
abaaaaabbbaababaabbaabab
aaabbbbbaaababaaabababaabbaababb
bbaaababbaabbbbababbbbbabbaabbabbbbbaaabbbabbabb
bbabbbbaabbbbbbbbaaaabba
aababbabaaabaababaabbabbabaaaabaaabbbabaaabbbabbbabaaaaa
babbbbbbaabbbaabbabbbabb
baabbbbaababbaabaaabbabb
aaabaabaabbbaabababbbbaaaaaabaabbabaabbbabaaabbbaaaabababaababbbababbabaaaaaabab
aabbabaabaaaaaaababbababaabaabba
ababbababbaabbbaabaabaababbaabbbaaaabbaa
aabbababaabbbbbbbaababaababbabba
baabbabbbaaaaaaaaaaabaaa
baabbbabaaabbabbbbbbbabb
babaabaaaabaaaaabbbaaaab
baaaaaaababbbbbaabbbbbab
bbabbbabababbaabbaaababa
bbbbabababaaaaababbabbbababbabaaabbaabababbababaaaaabbab
aabbbbbababbabaaabababaaaaabaababbbabbab
babbbbaabaabbbbabbbbbabb
aaabbbabbabaabbbabaaababbaaabaab
abbaaabbbbaaabbbbabbbbbbbbbbabaa
bbabbabaaaabbabbbbbababababbaaabbabaaaaababaaaba
bbaabaaaaabaaababaababbb
baabbaaaaaababbababbaabaabababbbabaaabbbbbbaaabbbbababaababaabbbbbabaaababbaaaabbbaaaaaa
aaabaaabbbbbaaaabbbbabba
abbbaabbbabbbaaaaabaabab
aaabbbaabbaabbabbaabbbbbbbabbaaaaaaabbbaaaaaabab
aaaaaaaaaabbaabaaabbbbaabbaaaaabaaabbaababbbbbab
bbbbababbabababbbbababba
abaaaabaabbbbaaaabbbbbbbbaababbabbbbaabbaabbbbbabaaabbbaaaaaabab
bbbbbbaabaabaaaaaaaaabbaaaaaaababbabbabaabbabbab
abbbbbbbbaaaabaaaababbabbbbbaabb
bababaabaababbbaabbaabab
abaaaabaabaabbabaaabbbbbbbaaaaaa
aaaaaabaababababbbaabbbabbaaaaba
abaabaabbbababbababbaabb
baaabbaabbbaabbbbabbabbb
baababaabaaabaaaabbabbbabababbaabbbbbbba
bbbaabbabbbabaabbaaabbaaaabababaaabbbbaaababbaab
abaabbbbabbabbbbaaaaabab
bbbabaababaabbbbbbbaaaab
abbaaabaaaaaaabaabaaaabaabbaaabbabbabbbbaabaabab
aabaaaaababbbaaaaaaababb
aaabbbaaabaabbbabbbbabaa
aaaaabaababaabbabaaaabaaabbaaaaa
aaaabaabababbbbbaaaaaaaaaabbbbbbbbbbbbababbbbabbbaaabaab
bbabbbabbaabbbbaaaabaabaabaaabbbaaaaaaababbbaaab
aabaaabaaabbababbabababa
babbbaaaaabbbaabbbabbababbbbbbbaabbababa
abbaabaabaabbaaaabaaaaaaababbaab
abaaaababbaabababaabbbababbabaabaaababbbbbbbabba
bbaaaabababbabababbabaabbbaaabbbbbbabbaa
aabbaabbaaabbbaabaaaaaab
bbaabbabaaaabbbabbabbabb
abbaaabbabbbaaaabbbbbaaabbabbabababbbbbbabaabbbbbabbaaaaabaababb
ababbaabbabbbbbbbbabaaaabbbbababbaaabbbabaabaabb
aaabbabaaabbbabaaaaabaabaaababbaabbbabbababbbbabaabbabbb
abbabbaaabababababbbabaaaaaabaabbabaabab
babaabaaababbaaaaabbaaab
aaaaaababababaababbaaaab
ababbabaaababbaaabbbaababaaaaabb
bbaaabbabaaaabaabbabaaaaaaaababbbbbabaaa
bababbbabbaabbabbbbbabba
bbaaabbaaabbbbaabababaabbabbaaaa
aaaabaabaaaaabbaababbaabababbaaa
ababbabaabbabbbbbbaababb
aabbbbbbbaaabbbababababa
bababbbaabbabbaabaaaabab
bbaaabbbaabbbbbaaabaabba
aabbbbaaababbbabbbaabbbb
baaaabaaabaaabbbababbbabaabbbabbaabbbaabbbbbbbabaaaabbaababbaabaaababbbb
babbbbabbbbababbabaaabba
babbbbaaababbbbbbabbbaaabaabbaab
bbbbbbaaaabbbabbaaabaaaabbbabaaaaabaabab
babbbbbabbabaaaaaaaaabbb
ababbbabbabaabbaaaabbabbaaaabbaa
bbbabbbabababbbabbaaabbbbbbbaaba
abbabbaaabaaababbaaaaabb
bbababbabababaaaaababbbbbabbbaabababbaabaabbbaababbaaaba
babbababaabbbaaaabbaaaab
abbaaabbbaaaaaaabbababab
bbbabbbabbabbabababbbbab
babbbaaabababaabaababbbababbbbbaabbbbaba
bbbababaabaabaabababbbbbabaaaababbabbbabbbaaabaababbaaaaabaaaabbaaaabbab
babababbabbabbbaaaaabbab
baabbabbabaabbaaababbbbb
aabbabaaaaaaabbaabbabbbaababbaabababbbbbbabbbababbbaaaba
aababababbbabbbaabbaaaaa
aabababaaabaaabaaabbaababbbabbaabbaaababbbbbbbababababbaabbbbbab
abbbaabbbbabbbbaabbabbab
aaaabbbbaabbaabbbabaaaaa
aababbababaabbbaaabaabba
baaaaabaaaaaabbababaabbbabaaaabbabaabbbaabaaabbaabaababaaaabbaaa
ababbaaabaababaabbbbbababaaabbbb
babbabababbbaaaabbbaabaa
baabbabbbaabbabaaabbbbaabbbaabbaabbabaababaaabaabbaababbbaaaabbb
abaabbbbaaaabaabbbbbbbba
baabbabaaaababaaabbaabbbbbbbbbbb
abbaaaabababbbbabababaabbbaaabbaababaabbbaaaaaaaaabaaaab
bbbabbabaaaabbababbaabababaaaabaaabbaaaabbbababa
bbbababababbbbbbababbbba
bbbbbbaaaaabbbaabaababab
aaaabbbaabbaaababaaababa
bbaaabbabbabaabaaaabaaaaabaaabbabaaababb
ababbabaabaabbaababaaaaa
bbbaabbaaaababbaabbbbabaaabaaaab
abbbabbbbbbabbaaabbaabbbababbbbaaabababb
bbbbbaaabaaabaabaabbaaab
bbaabbababaaababaaabbbabaaaababaabbaaababaabaaab
abbbabbbaabbbbbabbababbb
bbbaabbabbabbbabbaaaabba
bbabaabaababbbaababababaaabaabababaaaaaabaaababb
babaabaaaaaaabaaaabaabba
babbbbbaaabbbaaaaabbababbaababba
aababbaaababbbbbbabbabba
bbabbbabaabbaabbbbbbabaa
ababbababbbababaababbbaa
aaabbbaabbabaabaababbbba
bbaabbabbbabbaaabaabbbababaaabaabbbbbabbbbaaabaaababaaba
baababaabbaaabbabaaababb
abbaabbbababababaaababbbbaabaabb
baabbbbbaaabaababaababba
babaabaababaabbbbaabaabaaaababaababbabba
bbaaaaabaababbaaaabbaabaaabbabbbbababbaa
abbaaabbaaabbbbaaabbbbaaabbaaaabaabbaaabbaababbbabbabbabaaaababb
aaabbaabababaaaabaabaaab
bbaabbaabbbabaaabbabbbbbbbbabaabbabaaabababbbbabbaabbabbbbbabbaa
bbbabbbbbbabbbaabaababab
bbabbbbabbaabbbababbabba
aaabbbaabaabaababaabbabababbaaaabbbbbbba
babbaabababbabababbbbbbaababaabbbaabbbbababaaaabbbaaaaababbabaaabbbbaaaaabaaababbbbaabba
babbbabbbaaaaaaabbaabbbbabbbbabbaaabababaabbbbab
bbaaaaababaaabbaabbbaaaaaababbabbbaabaabaaabaaabbabaabab
baabbbbbabbaaababbbbaaabbbbbbaabbbbbbaabbaaaaababbaaaaaaaabbabba
bbabbbaaabaaabbbabbbabaaaababbaaaabbbaabababbbbabbababaaaaaababb
baaabaaaaabbababbbabbbbaabaabbbaaabbbaabbaaabbabbaaabaab
aaaaaabaaaaabbbabbbaabaa
bbaaabbbbabaaaabbabaaaabaabaaaaababaababaaaabaaaaababbbb
babbaaababbbaabaabbbbaab
aaabbaababbbbbabaaabbaaaaabbbbbaabaabaababababababbabbbb
babababbbaabaaaabaaabbbb
babbabaaaaabbbabbbbbbbaabbbaaaaa
aabbabaabaaabbbaaaaaabab
bbbabbaaabbbbabbbababbabaaabababaababaab
bbabaaaabaabbabbbbbabaabaaababbb
baababbbbaaaabbabbaabbbbbbbbbaaabbbbaaba
aabbaababaaaabaabaabbaba
bbbabbaababaabaaabbbaaaaabaaaabaaabaaababababaaabbababbbbbbbabba
bbabaabaabaaabaabbabbaab
aabaaaaaaaababbbaaababbbbbbaabab
baaaabaaabbbabbbabaaababbaabbaaa
baabbbbabababbbaaababbbabbabbbbabbaabbbaabbabababaaabababaabaabbbabbabba
baabaabaabababaabaaaabbb
abbaabbbbabaabaaababbababaabbabbbabbbbabbbbbaabababbaabb
abbbabbbbbbababaabbbabbabbbbbaab
abaaabbbbbbaabbbaabbaaab
ababbbabbbabbbaaabaaabaababababa
bbbbbbaaabbbaaaaaaabbabaabbbbaabbbbaaaab
bababbbbbabbbbbbbaabbbbbbbababbbbabbabbbabbbbaabbaaaabba
baaabbaaaaaaaababaaabbbaabaabaaabaabababaaabbaaaabbaabaa
aabbaabbbbbabaababaabaaaababbaaabbabbababbbbaabb
abbbbbaabbbabbbbbbbbaaba
aaabbabbbbbabbbababaaabb
abaabaaaaabbaaaababbbaab
aaaabaabbbbbaabababaaaaaaaaaaabb
bbbababaabbbabaabaababba
abbbaabbabaaababbbbbbabb
babbabbbaaaaabbbaababbabbaabbbbbbaaabbaaaabbbbbaabaababbbbaaaaba
aaaaaababbbababababaabab
bbaabaabbbaaaabbabbababaaaaaababaabaaabb
aabbabaababaaaababbbabab
ababbbababaabbbbbaaaabbbbbbbbaababbbbaaabbabbbaaabbbabbbbaaaabbbaaaaaaaaababaaab
bbbabaabaaaaabbaaaabaabb
babbaaabbaabaababbbbaaba
bbabaabababbbbbaabaabaaabbaaabbabbbabaaa
abbabaabbaaaabaabbbaaaba
aabbabaabaaabbbaaaabbbabbabababbbbbaabbb
aabbbbbbabababababbbbbab
abbabbbabbabaababaaabbbb
baaabbaaababbaaabaabaabb
bbbabbbaaaabaaaaabaaababaaaabbbbaabbaaaaabbbabab
aabbbabaaaababaabaaaaaba
abbbabbbababbabbbbaabbaa
abbbbbabaabababbbabababa
bbaabaabaababbaabababaaa
bbabaaabaababbbaaababbbaaaababba
abbaabaababbababaaaabbbaabbabaababbbaabaaaabaaabaabbbbab
babbbaaabbabbbaababbbbaaaabaababaaaabaaa
babababbabaaaabaaabbbabaaabbbabababaaaabbbabbaab
aabbbaababbaaabaababbaababaaabbbaaaaaabaababbaaaaabaaabbbbababaa
abbbabbbaaabbbbaaabaabab
abaabbaaaabbaabbbbbaaaaa
bbabaaabaaaabbbbaabbbaaaaabbbbbbabbbbbbabbbabaaa
bbbabbaababbbbbabbaaaaabbabaabaaababaababaaaaabb
abbbabbbababbaaabbabaaaaabbabbbabbabaabbbaaaaabbabbabaaabbbbbbbb
bababbbaaaabaabaabbababb
abbbbbbbabababaaabbaababbabaaababbaaaaaa
abbaabbbabaaaaabaaaaabbaabaaaaabababbbababbbabab
abbabbbbbbabaaaabbbabbbabbbbaaba
abbaabbbbaabaababaababba
bbabaaababaabbbaaaaaabbb
baabbabaaaaabbabaabbbbabbabbabbabbaaaaaa
babbbbbbababbababbabbbabaabbaaab
aaabaaabbbbabbbbaabbabbbbaaaaaabaabbbaabbaababaa
baabbbbbaaabaababababbab
babbaaabaaaabaababbabbaaaabaabaa
abaabbbbbbabaaaaaabaabab
aaaaabbaabababaabbbbbababbbababbbbaababb
abababababaabaaabbaaababbabbabbb
abaaaaabbbbbbabaaaaabbaa
aaaabbbbbbbbababbbabaabb
bbabbabaabaaabaaaaababab
aaabbbbbabbabbbbbabaababbbaabaababbababb
bbabaabaabbabbaaaabaabba
abbabaaababbaabaaaaabbbabbaaaaabbbaabbabbababaaabaabbaabbbbaaabaaaabbbaabbbbabba
ababbbabaaabbabbaaabbabaaabaabba
bbbabbbbbabbbbbbabaaabaaaaababbbbababaaa
babbabaaabbaaabbabbabaaa
babbbbaaabbbbbaaabaaabaabbbbababbaaababb
abbabbbbabababbbbbabbaaabaaababb
babbababbbaababaabbabbab
bbaaababbbbbaaababbbbabb
baaaabaababaabbbabaabbbaaabbbaabaaaabbab
abbaabbbbbaaaaabbbaabbabbaabbaab
aaaaaababbaababaaabaaabababbbabb
baaabbaabbbababaaababbbaaaaaabba
bbbbabaaaaabaaaaaaababbaaaababbbbbaabaaaaabaaaabaaaabbaabbbbbbbb
abaaabbbbaaabaaababbabba
aaaaabaaaaabbbaabbabaaaaabababaaabbbbbaabbaaaaba
ababbabababbbaaaaaaaabbb
aaababaaabaabbaababbabbb
ababababaabbbabbbaaabaab
baabbbabbaaabaaabaaabbbabbabbabb
bbbabbaabbabbababaabbbbaabaabbabaabaaabbbaaabbbb
aaabbbabaaabbbbbabbabbbbbbbaaaaa
aaabbababbaaababaaaabbaa
bbbabbaaababbbabaaabaabb
baababbabbbabaaababaaababababbaaaababaabbbbaaaabbabaaababbbabaababbabbbbbaaabbab
bbbabbaababaabbabbbbbaaa
abababaabaaaabaaabababbbbaababbbbbabbaaaaaabbaabbbbabababbabaabb
babbbababaaabbbabaababbbaaabababaaaababbbabbaabbabaabbba
bbbabbaabaabbbbaaaaaabaabaaabbab
bbbabbbbaabbaabaaaaabbbbbaabbabbabbaabaababbaabbaaabbaaa
aaababbbbaaaabaaabbabbbbabbbbaba
aaaaabbababaabbabaaaaaaaaaaaaababbbbbbaaababbaaaaabaabab
babbababbaaabbabbabbaaaabbaabaabbaaabbab
"""
    |> String.split("\n") |> Enum.split_while(&(&1 != ""))
    {rules, Enum.filter(input, &(&1 != "")) |> Enum.map(&(String.graphemes(&1)))}
  end

  def test_input2 do
    {rules, input} =
    """
42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: "a"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: "b"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1

abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaaaabbaaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
babaaabbbaaabaababbaabababaaab
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
"""
    |> String.split("\n") |> Enum.split_while(&(&1 != ""))
    {rules, Enum.filter(input, &(&1 != "")) |> Enum.map(&(String.graphemes(&1)))}
  end

end
