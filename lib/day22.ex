defmodule D22 do

  def play2(p1, [], _) do
    {:p1, p1}
  end
  def play2([], p2, _) do
    {:p2, p2}
  end
  def play2([p1|p1rest] = d1, [p2|p2rest] = d2, played_hands) do
    case {d1, d2} in played_hands do
      true ->
        {:p1, d1}
      _ ->
        new_played_hands = MapSet.put(played_hands, {d1, d2})
        case length(p1rest) >= p1 && length(p2rest) >= p2 do
          true ->
            p1_2 = Enum.take(p1rest, p1)
            p2_2 = Enum.take(p2rest, p2)
            case play2(p1_2, p2_2, MapSet.new) do
              {:p1, _} ->
                play2(p1rest ++ [p1, p2], p2rest, new_played_hands)
              {:p2, _} ->
                play2(p1rest, p2rest ++ [p2, p1], new_played_hands)
            end
          false->
            case p1 > p2 do
              true ->
                play2(p1rest ++ [p1, p2], p2rest, new_played_hands)
              false ->
                play2(p1rest, p2rest ++ [p2, p1], new_played_hands)
            end
        end
        end
  end

  def play(p1, []) do
    {:p1, p1}
  end
  def play([], p2) do
    {:p2, p2}
  end
  def play([p1|p1rest], [p2|p2rest]) do
    case p1 > p2 do
      true ->
        play(p1rest ++ [p1, p2], p2rest)
      false ->
        play(p1rest, p2rest ++ [p2, p1])
    end
  end

  def score(deck) do
    deck |> Enum.reverse |> Enum.reduce({1, 0}, fn c, {m, s} -> {m + 1, s + (c * m)} end)
  end

  def run1 do
    {p1, p2} = full_input
    play(p1, p2) |> elem(1) |> score |> elem(1)
  end

  def run2 do
    {p1, p2} = full_input
    play2(p1, p2, MapSet.new) |> elem(1) |> score |> elem(1)
  end

  def test_input do
    {
      [9, 2, 6, 3, 1],
      [5, 8, 4, 7, 10]
    }
  end

  def full_input do
    player1 = """
29
30
44
35
27
2
4
38
45
33
50
21
17
11
25
40
5
43
41
24
12
19
23
8
42
"""
    |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.to_integer/1)

    player2 = """
32
13
22
7
31
16
37
6
10
20
47
46
34
39
1
26
49
9
48
36
14
15
3
18
28
"""
    |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.to_integer/1)

    {player1, player2}
  end
end
