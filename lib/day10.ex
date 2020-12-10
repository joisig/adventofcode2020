defmodule Day10 do

  # This was correct but too slow for problem 2
  def combine_skipping(0, _) do
    [[]]
  end
  def combine_skipping(_, []) do
    []
  end
  def combine_skipping(depth, [first|rest]) do
    Enum.reduce(combine_skipping(depth - 1, rest), [], fn list, acc ->
      case list do
        [head|_] ->
          case head - first <= 3 do
            true -> [[first|list]|acc]
            false -> acc
          end
        _ ->
          [[first|list]|acc]
      end
    end) ++ combine_skipping(depth, rest)
  end

  def differences([head], acc) do
    acc
  end
  def differences([head|[next_head|rest]], acc) do
    differences([next_head|rest], [next_head - head|acc])
  end

  def run1 do
    list = [0|full_input |> Enum.sort]
    list = list ++ [Enum.at(list, -1) + 3]
    diff = differences(list, [])
    Enum.count(diff, &(&1 == 1)) * Enum.count(diff, &(&1 == 3))
  end

  def has_excessive_diff([_], _), do: false
  def has_excessive_diff([head|[next_head|rest]], max_diff) do
    case next_head - head > max_diff do
      true -> true
      false -> has_excessive_diff([next_head|rest], max_diff)
    end
  end

  # Correct but too slow for problem 2
  def generate_valid_n(input, head, tail, skip_n) do
    len = length(input)
    candidates = combine_skipping(length(input) - skip_n, input) |> Enum.map(&([head|&1] ++ [tail]))
    Enum.filter(candidates, fn candidate ->
      (candidate |> differences([]) |> Enum.count(&(&1 > 3))) == 0
    end)
  end

  # Correct but too slow for problem 2
  def generate_valid(input, head, tail, skip_n) do
    valid = generate_valid_n(input, head, tail, skip_n)
    case valid do
      [] ->
        valid
      _ ->
        generate_valid(input, head, tail, skip_n + 1) ++ valid
    end
  end

  def rests([], _) do
    []
  end
  def rests([head|rest] = input, first) do
    case head <= first + 3 do
      true ->
        [input|rests(rest, first)]
      false ->
        []
    end
  end

  def count_valid([must_reach], must_reach) do
    1
  end
  def count_valid([head|rest] = list, must_reach) do
    # Memoize, otherwise we calculate results for the same
    # lists billions (?) of times. With this, results are
    # near-instant.
    case Process.get(list) do
      nil ->
        r = rests(rest, head)
        result = Enum.sum(Enum.map(r, fn rest ->
          count_valid(rest, must_reach)
        end))
        Process.put(list, result)
        result
      result ->
        result
    end
  end

  def run2 do
    input = full_input |> Enum.sort
    tail = Enum.at(input, -1) + 3
    #generate_valid(input, 0, tail, 0)
    input = [0|input] ++ [tail]
    count_valid(input, tail)
  end

  def test_input do
    """
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
"""
    |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&(String.to_integer &1))
  end

  def full_input do
    """
18
47
144
147
124
45
81
56
16
59
97
83
75
150
33
165
30
159
84
141
104
25
164
90
92
88
2
8
51
24
153
63
27
123
127
58
108
52
38
15
149
66
72
21
46
89
135
55
34
37
78
65
134
148
76
138
103
162
114
109
42
77
102
163
7
105
69
39
91
111
131
130
6
137
96
82
64
3
95
136
85
9
116
17
99
12
117
62
50
110
26
115
71
57
156
120
98
1
70
"""
    |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&(String.to_integer &1))
  end
end

