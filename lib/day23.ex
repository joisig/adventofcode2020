defmodule D23 do

  def after_one(list) do
    index = Enum.find_index(list, &(&1 == 1))
    {before, [ignore|rest]} = Enum.split(list, index)
    rest ++ before
  end

  def insert(post, list, three) do
    post = case post <= 0 do
      true -> 9
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

  def move([curr|rest]) do
    {three, tail} = Enum.split(rest, 3)
    next = [curr] ++ tail
    [pc|rest] = insert(curr - 1, next, three)
    rest ++ [pc]
  end

  def run1 do
    start = full_input |> parse
    list = Enum.reduce(1..100, start, fn _, acc ->
      IO.inspect acc
      move(acc)
    end)
    after_one(list) |> Enum.reduce(0, fn el, acc -> acc * 10 + el end)
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
