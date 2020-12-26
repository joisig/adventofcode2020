defmodule D23 do

  def after_one(list) do
    index = Enum.find_index(list, &(&1 == 1))
    {before, [ignore|rest]} = Enum.split(list, index)
    rest ++ before
  end

  def insert(post, list, three, max \\ 9) do
    post = case post <= 0 do
      true -> max
      _ -> post
    end
    new = Enum.flat_map(list, fn item ->
      case item == post do
        true -> [item] ++ three
        _ -> [item]
      end
    end)
    case length(new) == length(list) do
      true ->
        insert(post - 1, list, three)
      _ ->
        new
    end
  end

  def move([curr|rest], max \\ 9) do
    {three, tail} = Enum.split(rest, 3)
    next = [curr] ++ tail
    [pc|rest] = insert(curr - 1, next, three, max)
    rest ++ [pc]
  end

  def to_map([first|_] = list) do
    last = Enum.at(list, -1)
    Enum.chunk(list, 2, 1) |> Enum.reduce(%{}, fn [key, val], acc -> Map.put(acc, key, val) end)
    |> Map.put(last, first)
  end

  def to_list(_, _, 0), do: []
  def to_list(_, nil, _), do: []
  def to_list(map, key, depth) do
    next_key = Map.get(map, key)
    [next_key|to_list(map, next_key, depth - 1)]
  end

  def map_take_n(map, _, 0, so_far), do: {map, so_far}
  def map_take_n(map, before_pos, n, so_far \\ []) do
    item = Map.get(map, before_pos)
    {next, new_map} = Map.pop(map, item)
    new_map = Map.put(new_map, before_pos, next)
    map_take_n(new_map, before_pos, n - 1, so_far ++ [item])
  end

  def map_put(map, _, []), do: map
  def map_put(map, after_pos, [item|rest]) do
    next = Map.get(map, after_pos)
    map
    |> Map.put(item, next)
    |> Map.put(after_pos, item)
    |> map_put(item, rest)
  end

  def index_to_use(map, cand, max) do
    case cand == 0 do
      true ->
        index_to_use(map, max, max)
      false ->
        case Map.get(map, cand) do
          nil ->
            index_to_use(map, cand - 1, max)
          _ ->
            cand
        end
    end
  end

  def move2(curr, map, max \\ 9) do
    {map, three} = map_take_n(map, curr, 3)
    index = index_to_use(map, curr - 1, max)
    map = map_put(map, index, three)
    {map, Map.get(map, curr)}
  end

  def run1 do
    start = full_input |> parse
    list = Enum.reduce(1..100, start, fn _, acc ->
      move(acc)
    end)
    after_one(list) |> Enum.reduce(0, fn el, acc -> acc * 10 + el end)
  end

  def run1_2 do
    list = full_input |> parse
    Enum.reduce(1..100, {to_map(list), Enum.at(list, 0)}, fn _, {map, curr} ->
      move2(curr, map, 9)
    end)
  end

  def run2 do
    list = (full_input |> parse) ++ Enum.to_list(10..1000000)
    {map, _} = Enum.reduce(1..10000000, {to_map(list), Enum.at(list, 0)}, fn _, {map, curr} ->
      move2(curr, map, 10000000)
    end)
    [x, y] = to_list(map, 1, 2)
    x * y
  end

  def parse(input) do
    input |> String.graphemes |> Enum.map(&String.to_integer/1)
  end

  def test_input do
    "389125467"
  end

  def full_input do
    "962713854"
  end
end
