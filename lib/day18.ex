defmodule D18 do

  def nacc(num, acc, op) do
    case op do
      :init -> {num, :num}
      :plus -> {num + acc, :num}
      :mult -> {num * acc, :num}
    end
  end

  def calc([], {num, _}), do: {num, []}
  def calc([tok|rest], {acc, op}) do
    case tok do
      :plus ->
        ^op = :num
        calc(rest, {acc, :plus})
      :mult ->
        ^op = :num
        calc(rest, {acc, :mult})
      :opar ->
        {num, rest} = calc(rest, {0, :init})
        calc(rest, nacc(num, acc, op))
      :cpar ->
        ^op = :num
        {acc, rest}
      num when is_integer(num) ->
        nacc = nacc(num, acc, op)
        calc(rest, nacc)
    end
  end

  # NOPE... mult here is too greedy
  def calc2([], {num, _}), do: {num, []}
  def calc2([tok|rest], {acc, op}) do
    case tok do
      :plus ->
        ^op = :num
        calc2(rest, {acc, :plus})
      :mult ->
        ^op = :num
        {num, rest} = calc2(rest, {0, :init})
        calc2(rest, nacc(num, acc, :mult))
      :opar ->
        {num, rest} = calc2(rest, {0, :init})
        calc2(rest, nacc(num, acc, op))
      :cpar ->
        ^op = :num
        {acc, rest}
      num when is_integer(num) ->
        nacc = nacc(num, acc, op)
        calc2(rest, nacc)
    end
  end

  def t_new_top(tree, tok), do: {tok, tree, :undef}

  def t_get_edge(:undef), do: :undef
  def t_get_edge({:subtree, _} = edge), do: edge
  def t_get_edge(num) when is_integer(num), do: num
  def t_get_edge({top, left, edge}), do: t_get_edge(edge)

  def t_set_edge(:undef, tok), do: tok
  def t_set_edge({:subtree, _}, tok), do: tok
  def t_set_edge(num, tok) when is_integer(num), do: tok
  def t_set_edge({top, left, edge}, tok), do: {top, left, t_set_edge(edge, tok)}

  def make_tree([], tree), do: {tree, []}
  def make_tree([tok|rest], tree) do
    case tok do
      :plus ->
        left = t_get_edge(tree)
        tree = t_set_edge(tree, t_new_top(left, :plus))
        make_tree(rest, tree)
      :mult ->
        tree = t_new_top(tree, :mult)
        make_tree(rest, tree)
      :opar ->
        {subtree, rest} = make_tree(rest, :undef)
        tree = t_set_edge(tree, {:subtree, subtree})
        make_tree(rest, tree)
      :cpar ->
        {tree, rest}
      num when is_integer(num) ->
        make_tree(rest, t_set_edge(tree, num))
    end
  end

  def calc_tree(num) when is_integer(num), do: num
  def calc_tree({:subtree, tree}) do
    calc_tree(tree)
  end
  def calc_tree({op, left, right}) do
    case op do
      :plus -> calc_tree(left) + calc_tree(right)
      :mult -> calc_tree(left) * calc_tree(right)
    end
  end

  def parset([]), do: []
  def parset([char|rest]) do
    case char do
      " " ->
        parset(rest)
      "+" ->
        [:plus] ++ parset(rest)
      "*" ->
        [:mult] ++ parset(rest)
      "(" ->
        [:opar] ++ parset(rest)
      ")" ->
        [:cpar] ++ parset(rest)
      num ->
        [String.to_integer(num)] ++ parset(rest)
    end
  end

  def parse(input) do
    input |> String.graphemes |> parset
  end

  def test(input) do
    input |> parse |> calc2({0, :init})
  end
  
  def tests1 do
    [
      {"1 + 2 * 3 + 4 * 5 + 6", 71},
      {"1 + (2 * 3) + (4 * (5 + 6))", 51},
      {"2 * 3 + (4 * 5)", 26},
      {"5 + (8 * 3 + 9 + 3 * 4 * 3)", 437},
      {"5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", 12240},
      {"((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", 13632}
    ]
  end

  def tests2 do
    [
      {"1 + 2 * 3 + 4 * 5 + 6", 231},
      {"1 + (2 * 3) + (4 * (5 + 6))", 51},
      {"2 * 3 + (4 * 5)", 46},
      {"5 + (8 * 3 + 9 + 3 * 4 * 3)", 1445},
      {"5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", 669060},
      {"((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", 23340}
    ]
  end

  def run_tests(tests \\ 1) do
    {tests, calc_func} = case tests do
      1 -> {tests1(), &calc/2}
      2 -> {tests2(), &calc2/2}
    end
    Enum.map(tests, fn {input, expected} ->
      {result, _} = parse(input) |> calc_func.({0, :init})
      {input, expected, result}
    end)
  end

  def run1 do
    full_input
    |> Enum.map(fn line ->
      parse(line) |> calc({0, :init}) |> elem(0)
    end)
    |> Enum.sum
  end

  def run2 do
    full_input
    |> Enum.map(fn line ->
      parse(line) |> make_tree(:undef) |> elem(0) |> calc_tree()
    end)
    |> Enum.sum
  end

  def full_input do
    """
(8 * (6 * 8 + 3) * 9 * 9 * 8) * 2
4 + (9 * (8 + 9 + 7 + 5 + 2) * (4 + 3 + 2 + 9 + 5 * 7)) * 2
(7 * 8 + 6 * 3) * 3 * 2 * ((5 + 7 * 8 * 8) * (9 + 6 * 9 * 7 + 6 * 7) + 8 + (7 + 2 + 3 + 7 * 5 * 5) * (5 + 8) + 5) * 6
4 * 9 * (6 + 7 + 6 + 5 + 7 + (4 * 6 + 5)) + 9 + (4 * 2 * 6) + 2
5 * ((3 * 2 + 2 * 7) + 9 * 6) + (6 * (5 * 4 + 4 * 2 * 3 + 9) + 8 * (4 * 4) * 7 * 2) + (9 * 7 + 5 * 4)
4 + (8 + 9 * 5) + 5 + 9 + 6 + 2
(4 + 4 * 2 + 2 + 3) + (9 * 7 * 9) + 2 * 9 + 9 * 5
6 + (9 + 4) + 4 + 6 * 7 * 5
4 * (8 * (4 + 4 + 8 * 7 * 6 + 8) * 8 * 9 + 7 * 7) * 8 + 2 * 9 + (5 * 7 + 3 + (8 * 8 * 3 + 3 + 4) * (8 * 5 + 4))
(7 + 4 + 6) * 6 * 3 * 6 * 8 + 4
3 + (7 * (4 * 3 + 7 * 8 + 3 + 3) * 8) + (7 + 9 + 4 + 3 + (4 * 7) * 5) + (3 + 8) + 2 + 3
4 + (9 + (8 * 3 * 8 * 6 * 4 * 9) + (5 * 4 + 5 + 8 + 5) + (7 * 8 + 3 * 4 + 8)) * 9 + 7 * 9
7 + (2 + 8 + (7 * 6 * 8 + 6) * 8) * 9 + (5 * (9 * 6))
(9 * (6 + 2 * 3 * 9 + 7 + 5) * 9 + (6 + 6 * 9 * 6)) * 6 + 8 * 8 + 2 * 4
(5 * (7 * 9 + 8 * 2 + 5 * 4) + (6 + 7 + 6 + 9) + (5 + 3 + 6 + 9 * 7) + 7 + (4 + 9 + 2 * 3 * 4 + 5)) * 2 * 8 * (2 * 9 * (8 * 5 + 3 * 8 + 5)) + (5 + 4 * 4 * 2) * 2
9 * (9 * 2 * 3)
(7 * 8 * (6 * 4) + 8) * 4 + (3 * (9 * 4 + 7 * 6 * 3 + 9)) + 2 + 5
(6 + (4 * 6 + 8 * 9)) * 6
9 + 5 * (9 + 6 + (9 + 7 * 8 + 2 * 9) * (4 + 6 * 5 * 8 * 2) + 2 * 8) * 8 * (9 + 5 * (4 * 9) * 3 + 3 + (4 * 2))
2 + (6 * 8 + 6) * 8 * (5 + 2)
6 + 8 + 8 + (9 * 8 + 2 * 4 + 4 + 2) * 2 * 3
((5 + 5) + 2 + (7 * 2)) + 8 * 5
((8 * 9 * 5 * 7 + 3) * 8 + 4 * 5) * 2 + 7 + 9 + (6 * 5 + 7 + 2 * 6 * (4 * 9 + 5 + 2)) + (7 + 2 * 4 + (9 * 3 + 6 + 6 * 7 + 6) + (9 * 6 * 2 + 3 + 5) * 4)
3 + (2 + 7 * (5 + 2 + 8 * 5) * 7 * 7 * 3) * 9 * 4 + 3 * 8
(6 * 3) * (2 + 4 * 5 + 5 * 3)
5 * (2 * 2 + 6 * 2 * 2) + 5 * 6 * 4 + (9 * 5 * (5 * 4))
3 + 6 * 2 * 6 + 8 * 9
5 + 4 * (2 + (7 + 2 * 8 + 5 + 9 * 7)) * 8 + (2 * (6 * 3 * 3) + (6 * 5) * 8 * 9)
7 + (2 + 9 * 2 + (2 + 4 + 8 * 4)) * 4 * 3 * (8 * 4 * (4 + 5 + 8) * 5 + 3)
8 + ((8 * 3) + 3 * 7 + 6 + 8) * 4 + 6 * 6
2 * (4 + 9 * 8 * 8 * 3 + 9) + 9 * (8 + 9 * (5 * 4 * 4 + 9) + (6 * 2 * 6 * 3 + 9 + 5) + 3 + 3)
((7 * 5 + 3) + 7 * 5) + 4 * 2 * 7 + 5 + 6
4 + 9 * (6 * 6 * 4) + (7 + 6) * (3 * 8 + 3 * 6)
(7 + 5 * 6 * 8 * (7 + 4 * 5)) + 9 * 6 + 2 + 7
4 * 3 * 4 * (2 + 6 + 6 + 2 + 6) + 8 * (6 + 6 * 3 * 2 * 6)
4 * 6 * 2 * (9 + 4)
4 * 3 * 6 + 9 + (3 + 5 * 9 * 3 + 3) * (8 * 3 * 7)
((6 * 7 * 9) + 2 * 5 * 4 * 8) * ((3 + 4 + 6) * 3 * 3) * 8 + ((3 * 8 + 9 * 5 + 6 + 8) * 2)
4 * 6 + 3 * 6 + 6 * (4 + 7 + (8 + 4 * 5 + 4) * 6)
2 + (6 + (5 + 8 + 4 * 5 * 6 + 6) + 4 + 2 * 2 * 8) * 9 * (6 * 6 + 9 + 7 * 8)
3 * 6
(9 + 8 * 9) * 4 * (3 + 5 * 3 + 5) * (6 * 3 + 6 + 9) * (6 * 9 * 3 * 3 * 4 + 9) * (6 + 9 + 2 + 8)
4 * (8 + 9 * 6) * 7 * 3 * (9 + 6 * 2)
(7 + 3) * (3 + 8 + 3 * 8 + (4 * 9 * 9 + 5)) + 4 * ((2 + 2 * 2 + 7 + 4 + 9) + 5 * (2 * 6 + 8 + 2) + 4 * (7 + 7 + 7 * 8 * 8 + 3) + 7) + 2
(7 + 4 + 5 * (3 + 5 * 2 + 3)) * 3 * (7 * 3 + 9 * (3 * 2 + 4 * 7 + 3 + 2) + 4) + (5 + 3 + (9 * 5 + 6 + 5 + 4 * 8) * 4 + 4)
4 * 6 + 7 + (3 * (4 + 2 + 4)) * 4 + (7 + (6 + 7) * 3 + 2 + 6)
6 + 3 * 5 * 2 * (4 * 9 + 6 + 5 * 8)
(6 * (3 + 2)) + (8 + (3 * 8 + 7 * 7) * 5) * (3 * (6 + 3 * 5 * 2 * 7 + 4) + 5 + 5 * (5 + 6 + 5 * 3 * 2 + 6)) + 6
(4 * 2 * 4 + 7 + 2) * 7 * (6 + 7 + (5 * 5 + 3) * (5 * 2)) + 5 + 2
9 * ((5 + 3) * 5 + 6 * 5)
((7 + 9 * 9 + 8 * 8) * 4 + 6 * 5 * 6 + 9) + (9 + 5 * 3 + 5 * 8 * 2) + 8 + 2
(7 * 4 * 6 + 5 + (9 + 5 * 5 + 5) + 3) + 5 * (3 * 4 * 6 * 5)
2 + (8 + 9 * (8 + 3)) * 2
(9 + 9 * 5 + 5) * 2 * 6 * (5 + (9 * 4 + 7 + 6 * 2) + 3 + 3) + (7 + 4 + 3 * 4 + (4 + 8 + 5 * 2))
(4 + (7 + 3) + (4 + 5 + 7 * 9 * 8) + 5) + (6 + 5) * (2 * 2 * 9) * 7 * 9 + 4
5 + 9 + (2 * (6 + 9 + 9 + 2 * 3 * 3) * 8 + 8 + 4) * (9 + 9 * 4 + 3 * 9 * (5 + 9 + 7 + 4 + 7))
2 + 4 + 2 * (5 + 9) + (3 + 2 * 8 * (9 * 5 * 3 * 6 + 6 + 5) + 7 + 9) + 5
6 + ((2 + 2 * 3 * 9) * (4 + 6)) + 2 + 3 + 2
2 + (2 + 5) * (3 * 8 * 5 + 6 + 7) * 6
2 + 2 + (7 * (4 + 4 * 7 + 3) + 2) * ((2 * 8 * 5 + 2 * 4 * 5) * 2 * 9 + (8 + 5 * 4)) + 9
9 * 9 + 7 + (9 + 3 * (9 + 2 + 4) + 3 * 4 + 9)
5 + (7 + 8 * (7 + 2 * 5 * 7)) * 8 + 6
(2 * (2 + 5) * 2 + 2 + 8 * (4 + 3 * 8 + 8 + 2 * 9)) * 9 + 9 * 7 * 2 * 9
4 * (7 * (8 + 6 * 2 * 6 + 2 + 7) * (5 * 7 + 5 * 2) + 5 + 5 + (3 + 8 + 2 + 5 * 8)) + 7
5 + ((4 + 5 * 6 * 5) * (6 * 2 + 2) * 8) * (9 + 9 + 9 * 3 * 4 + 2) * 3 + 2 * 4
7 + 7 + 3 + 9 + ((6 + 5) * 8 * 2) * 6
5 * 7 * 5 + (5 + (8 * 6) + (5 * 2) * 6)
(9 * 5 + 7 * 5 * 3 + 2) * 5
(5 * 2 * 2 * (4 * 8 * 6 + 7 + 3) * 7) * 8 * 3
(5 + 4 + 9 + (4 * 7 + 5 + 8) + 9) * 7 * (8 * 7 + 6 + 4 * 2) * 8
3 * 9 * 7 + 7
2 + 5 + 3 * (6 * 8 + 3 + 5 + (9 + 8 * 7))
2 * 3 + 5 * 3 * (9 + 2 * 9 * 9 * 9 + 2) * 9
8 * ((9 + 7) + 9 + 6 * 7 * (7 * 9 * 6 + 6 + 4)) + 3
4 + 5 * 7 + (8 + (7 * 6 + 5 + 5) + 7) + 2 * 5
2 + ((3 + 7) * 4 + (9 * 7 + 5) + 4) * 2
5 + 2 + 4
3 + ((5 + 9 + 8) * (5 * 2 * 9 * 6) + 6) + 9 * 2
4 * (3 * 3 + 2 * 2) * (5 * 8 + 6 * 2 * 5 + 4)
5 + 8 * 2 + (8 + 3 + 4 * 2 + 2 + 5) + (4 + 8) * ((7 + 8 * 3 * 9 + 5 * 5) + 7 + 7)
5 + ((9 * 8 + 2 * 8 + 3 + 4) + 6 * 5) + 4 * 8
2 + (8 + 4 + 6 + 2 + 6) * 5 * (5 + 7 * 7 * 6 * 5 + 4) + 9 * 8
3 * (9 * 9 * 4) + 3
4 * 9 * ((7 * 9 + 2 * 2 * 6 * 7) * 6 * 6 + 4) * 5 + 6 + 8
2 + 6 + 7 + 5 + (4 + 2 + 2 + (9 * 2 + 8 * 7) + 9) + 9
3 * (3 * 5 + 2 * (5 * 9 * 8)) * 8
((3 + 7 + 7 * 5) * 3) * 8 + 6 + 5 + 2 * 9
4 * 4 + (7 + (4 * 3 + 2 * 5 + 3) * 7 + 6 * (8 + 2 * 5 + 4 * 7)) + 4 * 7 * 8
7 * (2 + (4 + 6 * 4 * 8 * 7 * 6) + 5 + 8) * 5 + 2 + ((6 * 5 + 8 * 7 * 9 + 2) + 8 * 7 + 2 + 4) * (3 + 5 + (5 + 4) + 3 * 7 + 7)
9 + ((4 * 2 + 7 + 8) + 7) + 9
(6 * 7 * (5 + 9 * 9 + 9) + (5 * 9 * 8 + 5 + 2 * 2) * 5) * 2 * (6 * (7 * 3 + 5 * 7 * 9) * 2 * 5) + 5 * 2 + 8
7 * ((4 + 8) + 7) + 5 + 6
(8 * 4 + (5 + 4 + 7 + 3 * 4 + 5) * 9 + 9) * 2 * (3 * 3 + 5 + 4 * (5 * 5 * 5 * 9)) * 7
9 * 8 + 8 + (4 * 5 + 3) * 8
3 + 9 + (5 + 7 + 7) * 2 + 6
4 + 8 + (9 * 2) * ((5 * 5) + 5 + 8 * (6 * 3))
3 * 7 * 5 + 4 + (8 * 7)
(3 + 5) * 9 * 6 * (9 * 4 * 8) * 5
(9 + 8) * 3 * 9 + 3
9 + 6 + 9
(7 + 6 * (8 + 5 + 2) * 6 + 7 + 7) * 4 * (3 * 5) * 5 * 7 * 4
(9 + 3 * (4 * 2 * 3 * 9 * 7)) + 7 + ((9 * 8 * 4 + 2 + 4 * 7) * 7) + 2
2 + (6 + 9 * 3 + 6 + 5 + 4) + 8
4 * 7 + 5 + (7 + 8 * 7 * 4 * 7 + (6 + 9 + 3 * 6 * 9 * 8))
9 + 9 * 4 + 3 * 5
4 + (3 * 7 + 4 + (7 + 6 * 4 * 8 + 9 + 7) * 9 * 9)
(8 * (2 * 6) + 9 + 7 + 3) * 9 + 8 * (5 * 5 + 5) * (6 + 7 + 6)
(2 * 3 * (6 + 3) * 5 * 6) + 7 + 8
9 + 2 + 5 + (3 * (9 + 3 + 2 + 7 * 6) + (6 * 6 * 2 * 3 * 2 * 2) + 3 * 9 + 2) + (3 + 4 + 3 * 8 * 7) * 5
4 * 7 + 4 + 5 * (9 + 7 + 7 * (6 * 8) * 7)
(4 + 9 + (2 + 8 * 2 + 4) + 4) * 2 * 4 + 8
(7 * 8 * 7 + 7 + 5 + (6 + 7)) * 8 + 8 * 6
5 + 6 * 3 + 6 * (5 * 8 + 2 * 4 + 5) * 9
5 + (5 * 8 + 7 * 7 * (7 * 4 * 9 + 4 + 8 * 5)) * 9 + 8 + 5
5 * 6 + (2 + (3 + 3 * 6 * 4 + 5 * 2) * 7 * 7) + 8
8 + 6 * (6 * (9 * 5 + 9 * 9) + 6 + (4 * 2) + 6 + 9) + 9
8 + (3 + (6 * 2)) + 8
6 * (5 * 2 * 8 * 5)
4 * 2 * 7 + 7 + (3 + 2 + (4 * 6) + 5) * (2 * 6 + 5 + 7 * 2)
9 * 7 + 4 * 3
9 + (9 + (3 + 2) * (4 + 6 + 2 + 9 + 2) * 4 * 9 * 7) * 8
7 * 5 + (4 * 4) + 8
2 * 9 * 7 + (4 + 5 * 3 + 9 * 9 + 6)
8 * 4 + 7 * (5 + 3 + 3 + (2 * 5 * 2 + 6) + 7 + 3) * (5 * 9 + 2 + 5) * 3
((7 * 8 * 6 * 3 * 9 * 5) + (6 + 5 * 7 + 8) * 5 * 7 * 9 * 2) + 8 * ((2 + 6 * 9 + 8 * 8 + 3) + 8 + 5 * 4 + 8) + 7 * 8
6 + 3 * 2
(8 + (8 * 4 + 3 * 2 + 3)) + 2 * 4 * 3 + 3
(4 + 4) * (2 + 8 * 3 + (8 + 5 * 6 + 3) + 8 * 5)
8 + ((4 * 5 + 7) + 9 * 2 * 2 + (2 * 7 + 3 * 6)) + 4 + 2 * 4
6 * 8 + 9 + (3 + 2 + 4 + (2 * 2 + 7 * 5) + 3) * 3
7 * ((3 * 6 * 3) * (3 + 4 * 5 * 4 + 8) + 5 + (7 + 3 * 2 * 9) + 7 * 4)
6 * ((6 + 5 * 7 + 6 * 8) * 5 * 3) + 5 * 8 + 6
(4 * 7) + (2 + 8) + ((3 + 4 + 4 * 8 * 3) * 2 * 2 + 7) + 5
((2 * 5 * 9) + 8 + 4 * 7) * 3 + 8 * (6 * 4 * 3 * 2)
((2 * 4 + 2) * 2 * 4) * 9 + 5 * 6
3 * (8 * 3 + (6 + 3 + 4 + 6 * 6) * 7 + 8) * (7 * 2 + (9 + 4 + 3 * 7) + 3 * 7 + (4 * 5 + 3)) + (8 + 3 * 4 * 5 + (7 + 7 + 7) + 3) * 9 + 9
(8 + 9 + 5 + 3 + 3) + 6 + 6 + 9
7 + (6 * 2 * 3) + 8 * 8
2 * 7 + 4
(3 * (6 + 4) + (5 + 6 * 5 + 4) * 8 * 9 * 6) * 6
2 * (7 + 4) * (6 + (3 * 2 + 9 + 2 + 2 + 7) + 4)
5 * 8 * 4 + 5 + (6 * 7 + 3 * 2) + 2
(9 + 8 + 5) * 2 + 2 + 6
3 * 9 * (2 + 4 * 4 + 3 + 2 * 3)
6 + ((9 * 6 * 3 + 8) * 4 * 8 + 7) * 3 + 2 + 8
7 * 8 + (3 + 6 + 3) + 7
7 * (8 + 2 * 5 + 3 * 5 * 3)
2 + 2 + (3 + (7 * 7) + (7 + 3 + 4 + 3 + 3 * 5) * 4 * 7) + 5
(3 * 8 + 4) + 4 * (5 + 5 * 2) * 4 * 2
6 + 9 + (6 + 5) + 6 * (6 + 4 * 3 + 7 * 3 + 6)
2 + ((6 + 6 * 2) * 5 * 2 * (4 * 7 + 3 * 9 * 4)) + (3 * (2 * 8 + 6 * 4 + 9 + 2) * 2)
4 * ((5 * 9 * 2 + 3 + 3) * (5 * 8 + 9 + 8 * 5 + 7)) * (6 * 6 * 2 * 9 + 6 + 4) + 9
(4 * 9) + (2 + 8 + 7 * 6) + 7 + 7 * 7 + 8
8 + (9 + 5 + (5 * 2 * 6 * 2) * 4 * 9 + 7) + 8 * 3 + 4 * (5 + 4 * (2 + 2 + 6 * 8 + 9 * 7) + 2 + 3)
(3 * 6) * 2 + 3 + 3 * 3 + ((2 + 5 + 2 + 4 * 4) + 7 * 9 * 2 + 7 * 4)
(8 * 9 + 6) + 3 * 2 + (5 * 5 * (2 * 4 * 8 * 3) * (2 * 5))
9 * (6 * 6) * 2
8 + 6 * 4 * (9 * (8 + 7 * 6 + 8 + 5 + 8)) + 9
8 + 8 * 7 + (8 * 7) + 8
7 * ((6 * 5 * 5 + 9 * 6) * 4 + 3)
6 + 3 + 8 * 9 * 4 * (8 + 7 * 4 * 6 * 2 + 5)
(2 + 2 * 3 * 4 * (9 + 8 * 4) * 7) + 3
3 * ((5 * 6 * 9 * 2 * 6 + 4) + 3 * 2 + 7 + 5) + 5 * 2
9 * (4 + 8) + (6 * 5) * 4 * ((7 + 2 + 5 + 7) + 2 * 5 * 4) * (9 + 3 * (6 * 7 * 5 * 4 + 6) + (5 * 8 * 3 * 4 * 6) * 5 + (2 * 2 + 7 + 3))
4 + ((8 * 3) * 4 * 7 + 2 + 8) + (4 + 8 + 6 + 2) * 5 * 2
4 * (2 * 5 * 8 * 2 + 7 * (9 * 7 * 6 + 3 * 2 + 9))
3 + ((4 * 6 + 3 + 6 * 5 + 3) * 3) + 2 + 7 * (3 + 2) + 7
(9 + (4 + 8 * 4 + 6 * 4) + 4 * 9) + (4 * 6) * 6 + 3
(4 + 5) * 8 * 2 + 3 + 5
3 + (6 + (6 + 7) * 8 + (4 * 8 * 6 + 4) * (6 + 2 * 7))
8 + 8 * (9 + 8 + (4 * 6 * 6 + 2 * 3 * 4) + (8 + 2 + 3 * 7 + 4) * 9) * (2 + 9) * (9 * 7 * (6 + 4 + 5 + 3 + 8 * 5) * 9 * 7)
7 * 6 * (8 * 2 + 8 * 8 * (9 * 5) * 5) * 3 + 6
5 * (2 * (5 + 6 + 3) * (9 * 6 + 6 * 2 * 7) + 6) * 5 * 4 + 2 + (6 * (3 + 9 * 8))
(3 + 6 * 8 * 9) + 8 + 3 * 2 + 2 + 2
4 * 7 * (3 * 5 * 5 + 8 + 5)
(5 + 2) * 6 + ((9 + 3 * 7 * 5) * 6) + 8 * 9
7 + 5 + 8 + 8 * (9 + 4 * 5 + 4 * 4 * 9)
5 + 7 * 2 + 8 + 2
9 + ((2 + 9 * 6) * 8 * 9 + 2 + 2) + (6 * (7 + 3) + 3 + 3 * 7) * 3 * 3 + 9
8 * (5 + 8 + 2 * 4 * 2) + ((2 + 4 * 7) * 8 * (4 * 8 + 2 + 2 * 6 + 8) + 2) + ((8 + 3 * 6 + 9) + (5 * 3) * 8 * 7 * 8)
9 + 4 + (4 + 9 + 7 * 6) + 3 * 6 + 9
9 + (2 * 5 + 7 + 5 * (6 * 2 + 5 + 2 + 3 * 5) + 3) + 2 * (3 + 9 * 4 * 8) + 3 + ((9 + 3 + 7 * 2 + 7 * 5) + 7 * 5)
7 * 4 * 6 * ((9 + 9 * 2 * 4 + 2 * 2) * 7 + 9) * 8
6 * 5 + 4 * ((4 * 9 * 7) * 8 + 6 + 7) * 7 + 3
9 + 9 * 9 * 4
8 * 6 + 7 * ((9 * 4 * 2 + 9) + (6 * 9 * 2 + 2 + 5) + 8 * 6 * 6)
3 * (6 + 9 * (9 * 3)) + ((5 * 6 + 7 * 5 + 4 * 3) + 5 * 6 * 9) * 5 * ((8 * 2 * 6 * 5) + 5 * 8 + 5 + 9)
4 * (6 + 6 * 7 * 5 + 8) * 6 + 2
((9 * 8 * 3 * 6 + 2) * 4 + 7 * (5 * 8 * 2 + 4 + 9)) * 2 + ((7 + 3 * 3) * (7 + 3) * 3) + 7
8 * 4 * 9 + 8 * (8 + (6 + 6 * 2 + 4 * 4) * 3) + 8
(9 + (8 * 8 + 9 * 6) * 7) + 7 * 9 + 6 * 4
3 * 7 + (6 * (5 * 5 + 2 * 8 + 7 * 2) + (2 + 2 + 5 + 4 + 9) + (4 + 5 * 3 + 8 * 7) + 9 + 9) + 2 * 4
9 + (3 + 9 * (9 + 9 * 4) + 5) * 8 * ((6 * 8 * 4 * 9 + 9) * 5 + 2 * 9)
7 + ((5 + 6 + 5) * 8) * 5 + 9 + 5
2 + 2 + 9 + ((2 * 8 + 3) + 9 + 7) + ((6 + 3 + 2 + 8) + (4 * 7 * 6 + 2))
3 * 6 + ((6 * 6 + 7) + (2 + 3 * 7 + 4) + 4 * 2) * 2
9 * 3 + (9 * (6 * 5 + 6 * 2 + 7) + (5 * 7) + 3) * 6 * 9 + 3
5 + 9 + (9 * (4 + 5)) + (9 * 2 * (3 + 7 + 2 + 6 + 8) + 6 + 2) * 7
4 * 3 + ((7 * 4) * 3 * 4 + 7 + 9 + 7)
2 * ((3 * 6 + 3 + 3 + 9 + 2) * 4 + (5 * 8 + 4 + 6 + 5 + 8) * 5) + 9 * 5
4 + 9 * 3 * ((2 + 2 + 5 + 2 * 3 * 4) * 6 * 8 * (5 + 3 + 7 * 9 + 4) * (2 * 4) + (4 * 2 * 2))
5 + 7 + ((4 + 5 + 5 + 6) * 5 + 9 + 6) * 9 * 7
((6 * 8 + 5) + 8 + 3 + (4 * 5 * 9 * 2 * 9 + 6) + 7) * 9 + (6 * (8 + 6 + 4) * (6 * 9) + (9 * 2 + 8 * 4 * 8 + 5) * 9 * 5) + (5 * (7 + 5 + 3) * 5)
((4 * 6 + 4 * 2 * 4) * 9 + 5 * 9 + 5 * 9) + (3 * 7 * 9) * 7
2 * 2
(3 + (5 + 6) + 3 * 4 * 5 + 3) * 7
5 + 7 + 2 + 3
(8 * 7 + 9 * 9 + (3 + 9 * 7 * 7 * 9) * 6) * 4
8 * (9 + (3 + 4 + 7 * 5 * 9) + (8 * 4) * 4 * 7) * (8 + 3 + 5 * 9 + 8) + 2
9 + 2 + (3 + 3 + 8) * 2 * 3 + (3 * 9 * 5)
4 * 9 + 5 + (8 * 8 * 4) * 8 + 3
6 * 5 * ((9 + 9 * 9) * (3 * 5) * 3 + 6 + 8) * 2
4 * ((2 + 2 * 8 * 6 + 5 + 7) + 6 * 8 * 7 * 6)
(9 + 3 * (4 + 5 * 8) * 5 + 9) + (9 * 4) * (3 * 3) * 8
(2 * 3 * (6 * 5 + 8)) + 7 + ((5 * 7 * 5 + 9) + 9 * 3 + 2 * 2) + (3 * 5 * 8) * 2 * 4
3 * (8 + (6 * 3 + 9 * 7 + 2 * 5) * 2) * 3
7 * (3 + (8 * 9 + 9 * 6 * 4) * 8 + 4 + 6 + 7) + 7 + (9 + 5)
8 + 4 + 7
((2 * 8 * 5 + 3 + 9) * (9 + 6 * 8 * 3 * 5) * 2 + 7 + (2 + 2 * 4 + 5) + 9) + 8 * 7 * 6 * (4 * 8 * 3 + 7 * 7 * 9) + 4
(2 + 3) + 8
5 * 7 * ((6 + 6 + 8 * 2 + 4 * 5) + (6 + 9 + 8 + 8 * 6)) * 8 + 3 + 2
(3 + 9 + 7 + 5) + 6 + 3
7 + ((2 * 5 + 8 + 7 * 3 * 2) * 9 + 5) + 9
4 + 2 * 4 * (5 + 8 * 8 * 5 + 6)
5 * 9 * (6 * 3 * 7 * 7 + 9 + 6) * 7 * (6 + 2 + 7 + 9) + 5
4 + (5 * 2 + (5 + 4) * (2 * 3 + 4 * 5 + 4) * 3 * 2) * ((9 * 6 * 5 + 7 + 7) + 7)
(7 + (5 * 9 * 3 * 8) * 4 + 2 * 7 + 2) * 5
((4 * 8 + 9) + (3 * 7 * 7 * 7) * (9 * 3 * 2) * (8 + 4 * 6 * 9)) * 7 + 3 * 7 + 2
(8 * 3 + 8 + 2 * 3 + 3) + 2 * 3
5 * (5 * 8 + 3 * 4 * 3 + 6) + 7 + 7
5 * (7 + (4 * 9)) * 3 + 7
8 * 9 + (9 + (2 * 2 * 8 + 6)) * 6
4 + ((9 * 6 * 7 * 6 + 8) * 6 * 2 + (9 + 7 + 2 * 7 + 4) + 6) + 5 * 4 + 7
(5 + 3 * 9 + (4 + 7 + 5) * 2 * (8 * 4)) * 5 + 3 + 6
9 * 4
2 * (3 + (9 + 6 * 4 + 7 * 5 + 4) + 7) * 6 * 4 + 8 + 7
(2 * 9 + 3 * 2 + 8) * 5 * 8 + (9 * 3 * 2 + (9 + 4 * 8) * 6) + 7 + (8 + 7 + 8 * 2 * 2)
(9 + 7 + 5 * (6 * 4 * 7 + 9 * 9 + 2) * 2) + 7 * (6 * (2 + 7 * 3 * 8 * 3 + 3) * 7 + (4 * 4 + 5 + 6 * 9))
(2 + (6 + 8) * 6 + 9 * 4 * 2) * 9 * 6 + 8
6 * (5 * 8 + 7) * (4 * 3 * 6 + 4 * 4 * 5) * 6 * (7 * 4 + 5)
2 + (8 * (7 * 7 * 2) * 2) + 3 + (4 + 5 * (8 * 4 + 2 * 3) + 7 + 8) * 4
3 + ((7 + 5 + 3) * 7)
(5 + 6 + 7) * 3 + ((9 + 2) + 8 + (9 + 5 + 8 + 4 + 7 * 4) + 4)
((4 * 2 * 5 * 6 + 6) + 2 * 9 + 6 + 3) + 6 * (8 * 8 + 5 + (9 + 4 * 2 + 2 * 7 * 7) * 6) * 8
(5 * 9 * 8 * 7 * 5 + 4) + 6 * 4 * 5 * 9 + 5
5 * 5 + 5 + (9 * 3 + 3 + 7 * 4) + 6 + (7 + 2 + 5 * 6 * 4 + 4)
(5 * 2 * 7 + 9 + (6 * 9 + 2 * 3)) * 3 * 7 * 6 + 5 * 9
5 * (6 * 5 + 9 + 5) * 9 + (5 + 6 + (4 * 3 * 9 + 4 + 4 * 4) + 3)
((2 * 2) * 7 * 9 * 2 * 5) + 3 + (8 + 9) + 7
7 * (3 + (8 * 9 + 3 + 8 + 2) + 8 * 9 + 5 + 7)
8 * (4 + (6 * 3 + 6 * 5 * 6 + 5) * 9 * (4 + 3 + 5) + (7 + 4 * 6 * 3)) * 2 + 7 * 2
(8 + 9 * 7 * 8) + 7 * 3 * 9 * 3
7 + 6 * 4 * (9 * 8 + 6 + 7) * ((2 * 8) * 4 + (6 * 8) * (7 * 6 + 8 * 3) + 5 * 7) * 7
(4 + 9 + (3 + 2) + (5 + 3)) * 9 * 7 + 3 * 4 + 4
8 * (3 + (9 + 5 + 9 * 3) * 9 * 7 + 3 * 9) + 6 + 6
2 + 3 + (4 * 6) * (5 * 9 * (2 + 3 + 7 * 8 * 4) * 8 * 3)
3 + 8 * (2 * (7 + 8 + 6 + 7 + 7))
((8 + 7 * 7 + 6) + 5) + 3
7 * 3 + (2 * 5 * 9 + 8) + 8
2 * 5 * (7 + (6 + 9 * 5 * 2 * 6 * 6) * 8) + 6
((4 * 3 + 3 + 3 + 6 + 9) * (9 + 2) * (5 * 8 * 9 + 6 * 4) + (9 * 8)) + 6 + 8
((7 + 9 + 2 + 7 + 4) * 8 + (4 * 7 * 4) * 4) + (5 + 8 + 6) + 5 * 9
(8 * 6 * 7 * 7 + 7) + 2 + 5
2 + ((8 + 3 * 7 + 7 * 7) * 2 + 8 + (4 * 8 * 5 + 4))
9 + 2
4 * 7 * (3 * (9 + 8) * 8 + 2 * 8) * (8 + 2 + 6 + 3) * 8
6 + 3 * 7 * (2 + 5 + (3 + 8 + 9 * 2 * 3 * 4) + (7 * 9 + 6 + 4) * 2 * 6)
(5 * 2) + 3 + (4 * 8 * 9) * 7 * 7 + ((7 * 3) + 9)
8 * (3 * 4 * 5 + 8) * 7 + 3
5 + (6 + (7 * 8 + 2 * 4) + 2 + (4 + 2 + 9 * 7 + 4 + 6) + 5 + 5) + ((5 + 9 + 3) * 6 * (9 * 7 + 4 * 5 + 8) * 3 * 8) * 6
(9 + 6 * (7 * 4 + 3 + 7 + 9 + 5)) * 5 * ((7 + 7) * 4 * 7) + 6
5 + (9 + 3 * 6 + 2 * 9) + 5 * 3 * 5 + 6
9 * ((7 + 5 + 2) + (4 * 8 + 7 + 9 * 5) * (8 + 9) + 8) + 5
3 * (4 * 8) + 2 * 4 + (6 + (9 * 3 * 9) * (3 + 3 + 6 + 2 + 8)) * ((5 * 4 * 9 + 2 + 4) + 7 + 8 * 2)
(2 * 3) * 4 * (4 + 6 * 3)
5 + (4 * 4) + 2 * 8
(4 * 5 * 5 + (6 * 9 + 9 * 6) + 2 * 7) * (4 + (5 * 6 + 5 * 8))
5 + ((3 + 5) + 5) + 5 + 6 + 5
6 * (4 * 3 + 6 + 3 + 9 + 5) * (7 + 6) * 2 * 7
5 + 5 * 5 + 2 * (2 + (7 + 8 * 9 * 6 + 4) + 4 + 2)
9 + ((8 + 6 + 4 + 4) + 5 * (5 + 3 * 6 + 2 + 2 + 8) + (3 + 9 * 5) + 4) + 4
5 + 3 * 9 * (8 + 3 + 9 + 2) * 7
(5 * (3 + 5 * 2 * 3)) * 9 + 5 * 4
9 * 6 * 8 + (4 + (5 + 6 * 9 * 5 + 7) * 6) * 2 * 2
8 + 2 * 4 * (5 * 3 * 2 + (7 + 3)) * 9 + 3
2 + 3 * 9 * (4 * 4 + 3) + 2 + (7 * 2 + (2 + 6 + 8 * 7 + 6 * 2) + (4 + 3 + 3 + 3 * 5 * 5))
2 * 2 + (9 + 6) + 5 + 5 + 8
6 + 5 * (6 * 2 + (2 + 2) + 7)
5 + 7 + (7 * (3 + 7 + 7) * 9 * 2 + 8 + (6 + 7 * 8 * 3))
(6 * 5 + 7 + 5 + 7) * (4 + (5 + 6 + 4 * 7 + 4 + 4) + 6 * 9 * (5 * 7 + 9 * 5 * 6) + (2 + 8 * 4 * 6)) + (4 * 5 + 7 * 9 * 3) * 4 * ((2 + 8 + 9 + 2 * 8 + 3) * (4 + 3 + 2 + 7 + 7 * 6))
2 * 6 * 4 * ((5 + 9) * 5 * (6 * 7) * 4 * 8)
(7 + 4 + 8 + 2 + 5) * 2 + 3 * 6 + 7
6 + 3 * (6 * (2 * 4 + 7 + 3) * 6 * 9 + 4 * 3) + (5 * (4 + 9 * 5 * 5 * 2 + 2)) + 2
9 * 9 * 9 * 3 * ((9 * 9 + 6 * 2 + 6 * 5) + 7) * 6
(3 + 8 * 8 + 8 * 8) + (5 + 3 * 5 + 4 + 6) + 9
6 * 8 * 4 + (8 + 5 * 2 * 7)
4 * (2 + (8 + 3 * 9) * 3) + 2
(2 * 9) * 8 + 4 * (4 + (7 * 6 * 9) + 4 + (5 * 5 + 7 * 7 * 9) * 2) + 3 * 9
((4 + 7 * 3 + 4 * 2 + 3) + (9 * 3 * 9 + 6 * 8) + 9) * 3 * 5 + (5 + 4 * 5 * 6)
(8 * 2 * 9 * 6 * 3 * (5 + 6 * 2 + 9 * 4)) + 3
3 + 3 * 7 + 3 * 4 + 5
8 + (7 + 5) * 8 + 3 + ((8 * 7 + 8 + 6 + 6 * 3) + 7 + 2)
3 * 4 * (4 + 3 * 6)
3 + (8 * 4 + 8 + 9 + 6)
6 * 9 * 6 * 2 * (7 * 6 * 2 + 3 * (8 + 6)) + (5 + 7)
6 * 7 * 6 * 7 * 8
6 + 9 * (2 * (2 + 2 * 9 + 4) * 2 + 6 * (5 * 8 * 5 + 3 * 5)) + 4
8 * 3 * 3 * 3 * 8 + (3 + (3 * 8 + 7) + 5 + 2)
7 * 2 * ((8 * 7 + 3) + 3)
2 * 9 + (7 * 6) + (5 + 8) + 7 + 9
9 + 4 + (6 + (7 * 3 * 9 + 3 + 7) * 4 + (2 * 9 + 3 * 2 * 6) * 3 + 6) * 2 + (5 + (6 + 2 * 4 * 5 * 3 + 7) + 5 * 3 + 7 + 6) + 3
2 + 2 + 4 * 5 * 9 * 2
7 * 2 * 3 + 8 * 6 * 5
5 + 6
(3 + (6 + 7 * 2) + 8 * (2 + 4 + 4 + 5 + 6)) * 6
(4 * (2 + 3)) + (8 * 3) + (7 * 8 * 8 + 3 + 9 * 4)
8 + (8 * (2 * 5) * 8 * 7 * 2) + 7
6 * (6 * 8 + (9 * 5 + 2 + 9 + 3 * 6) * 8) + 7 + 6 * 6 + 2
2 * 7 * ((7 * 3) * 7 * 2)
2 * (9 + 8) * 3 + 8 + 7
(6 + (2 * 2 * 2) + 9 * 6) * 6 + 9 + (7 * 4 + 8)
4 * 7 + 7 * (3 + 2 * 4 * 8 + 6) + 9
8 + ((6 * 4 * 6 * 3 * 2) * (9 + 5 + 4 * 4 + 5 + 9) * 3 * 3 * (4 + 5 * 8 + 5 + 6) + (9 + 8 * 9 + 6 + 8 * 7)) * (9 * 9 * 2) * 5 * 3 + 2
5 + ((3 + 7 * 9 * 6 * 6) + 8 + 3 * 3 + 8 + 4) + (4 * 8 * (4 * 9 + 8))
((6 * 4 + 2 + 7 * 4) * 2) + (8 + 9) * (8 * (2 + 7 * 7 * 4 * 9 * 3) * 7 * 7 + 4) * 3 * 4 * 7
(8 + (9 * 6 + 5) + (4 + 5 * 4)) + 9 + (3 * 8) + 6
((3 + 7 + 9) + 3 + 3) * 4 + 2 + (6 * (8 + 4 + 3 + 4) + 3) * 7
((7 + 9) * 4 + (7 + 8 * 6 * 5 + 8) + 2) * ((3 + 4 + 7) + 2 * 3 * (5 * 6 + 6 * 4 * 4) * (5 + 2) + (3 * 4 * 4))
5 * (8 * 6 * 3 + (2 * 8)) + 2 + 5 * 2 + 6
4 * 5 + (8 * 4)
(4 * 5 + (8 + 7 + 5 * 8 * 5 * 8) + (2 + 7)) * 2 * ((8 * 3 + 5 + 9 + 3 + 5) + 3 + 5 + 8) * (3 + 8 * 6)
(7 * 6) * (2 + 8 + 6 + 3 * 5) * 2
3 * 7 + 5 * 2 * ((9 + 8 * 7 * 4 * 2) * 5 + 4 + 9 * 4 * 5)
9 + 7 * 3 * ((7 + 3 + 2) + 8 * 4 * 4 * (7 + 5 * 6)) + 4
((2 + 9) * 4 * 7) * (8 + 9 + 4 * 8 + 6 + 2) + (9 * 4 * 9 * 6 * 6 * (6 * 4 + 6 * 4 * 7 + 3)) * 6 * 3
(4 * 4) + 6 + 4 * 7 * (4 + 8 + 9 + 9 + 3) + 3
6 + 3 * (7 * 3) * 8 + 9
6 * 3 * 2 * 3 * 4
9 * (5 + 6 + (2 * 9 + 6 + 8 * 7) + (2 * 5 + 7) + (5 * 2 + 9 * 3 + 7 + 7)) * 6 * 5 * (9 + 6 * (5 + 2 * 8 * 9 * 5 * 9) * 3 + 6)
8 + 4 + 2 + (3 * 3 * 2 * (9 * 7 * 8 * 2)) + 4 + 7
(3 * 6 + 9 + 8 * (6 * 4)) * 7 * ((5 * 9 * 2 * 2) + 3 + 4 + 8 + 5) + 3 * 7
(2 * 4 + 4 + (8 * 2 + 8 + 6 + 2) + 4 + 9) + 9 * (2 * 6 * (4 * 3 + 7 + 6 * 4 * 7) + 3 * 2) + 3 + 8 * 7
7 + 7 + 8 + (9 * 7 * (6 * 8 * 2 + 7 * 4)) * 5 + 9
(9 + (8 + 8 * 7) + 2 * 3) + 3 + 5 * 2 * (5 + 4 + 2 + 6 * 8 + 5) + 8
4 * 4 * 4 * (2 + 6 * 7) * (5 + 4)
7 + 7 * 8 + 4 + (6 + 4 + 4 + 5)
((3 + 6) * 6 * 7 * (5 * 6 + 5)) + 2
((9 + 9 + 4) * 7) * 7 * 7 * 3 + 6 + 4
9 + 2 * 9 * 5 * 8
3 * (7 * 7)
6 * 2 + 3 + 2 * ((6 * 6) * 3)
2 + 6 * ((9 + 7 * 3) * 7 + 8 + (3 + 9) * 7) + 5 * 3
6 + 6 * (8 * 5) * (2 * 3 + 5 * 8 * 5 + 2)
(5 + 5 * 4) * 2 + 3 * ((4 * 6 + 2 + 9) * 9 + 7) + 8 * (7 * 8 * 5 * 7 + 4 * 9)
5 + 8 + (4 + (5 * 6 * 6 * 5 + 4)) * 4 + 2
6 + 2 + (4 * 7 * 7 * 2 * 8 + 8) + 7
8 + ((5 * 9) + (8 + 8 + 6 + 7 + 6 + 3) * 9) + 7 + 7
5 + 5 * 3 + 8
(6 + 4 + (8 * 2) * 5) * 3 * 6 * 8 + 3
(4 * 2) * 2 + 2 + 5 + (7 * (6 * 5 * 6 + 4) * 8 * (8 * 2) * (9 * 5 + 4 * 3 + 6 * 4) * 3)
8 * (3 + 7 * 5 * 4) + 4 + 4 + 6 * 8
(5 * 7) * 5 + 9 + (4 + 8 * 9 * 5)
3 * ((5 + 9) * 4 + 6 * 7) * 2 * 3 * 8
7 * (6 * 9 * (6 * 9 + 3 + 6 * 4) * 5) + ((8 + 5 + 2 + 4 + 8) + 4 + 9) + 8
7 + (3 * 5 * 7 + (4 + 9 + 3 + 6 + 7)) + (5 + 8 * (7 + 5 + 7)) + (7 * 4)
(4 + 7 + 2) * 2 + 9
6 * 4 + 9 + 6 * 6 + 7
6 * ((7 * 6) * 7 + 4 * 5 * 6 + 4) * (9 * (9 + 3) * 7)
(4 * 5 + 4 * 2 + 3 + 3) + 8 * 6 * ((3 * 4 + 5) + 2 + 3 * 8 + 6 + 9) * 8
((5 * 2 * 6 + 3) + (7 + 3 + 3) * (5 + 9)) * 7 * 6
5 + 6 * 4 + (7 + (3 + 3)) * (9 * 9 + (2 * 4 * 4 + 3) * 5 + 5 * 4) + 5
3 + 5 * (6 + 9 + (7 + 3 + 3 + 7) * 4 + 2 + 8)
5 * 5 + (5 * 6 * 5) * 5 * 2 + (3 * 5 + 9 + 6)
6 * (8 * 7 * 2 + 6) * 3
"""
    |> String.split("\n") |> Enum.filter(&(&1 != ""))
  end
end