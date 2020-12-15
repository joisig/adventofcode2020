defmodule D15 do

  def start(init) do
    Enum.reduce(init, {1, %{}}, fn num, {this_round, map} ->
      {this_round + 1, Map.put(map, num, this_round)}
    end)
  end

  def gen_until({this_round, map}, last_disposition, end_at_round) do
    to_speak = case last_disposition do
      :never_spoken ->
        0
      {:spoken, diff} ->
        diff
    end
    case end_at_round == this_round do
      true ->
        to_speak
      false ->
        new_map = Map.put(map, to_speak, this_round)
        case Map.get(map, to_speak) do
          nil ->
            gen_until({this_round + 1, new_map}, :never_spoken, end_at_round)
          prev_round ->
            gen_until({this_round + 1, new_map}, {:spoken, this_round - prev_round}, end_at_round)
        end
    end
  end

  def test1 do
    input_to_list("0,3,6") |> start |> gen_until(:never_spoken, 10)
  end

  def run1 do
    input_to_list("11,18,0,20,1,7,16") |> start |> gen_until(:never_spoken, 2020)
  end
  
  def run2 do
    input_to_list("11,18,0,20,1,7,16") |> start |> gen_until(:never_spoken, 30000000)
  end

  def input_to_list(init) do
    init |> String.split(",") |> Enum.map(&String.to_integer/1)
  end
end
