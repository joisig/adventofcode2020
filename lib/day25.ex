defmodule D25 do
  def transform(acc, subject) do
    acc * subject |> rem(20201227)
  end

  def find_loop_sizes(targets, nil, val, count) do
    results = List.duplicate(-1, length(targets))
    find_loop_sizes(targets, results, val, count)
  end
  def find_loop_sizes(targets, results, val, count) do
    case Enum.count(results, fn r -> r == -1 end) do
      0 ->
        results
      _ ->
        results = case Enum.find_index(targets, &(&1 == val)) do
          nil ->
            results
          index ->
            results = List.replace_at(results, index, count)
        end
        find_loop_sizes(targets, results, transform(val, 7), count + 1)
    end
  end

  def transform_with(subject, loop_size) do
    Enum.reduce(1..loop_size, 1, fn _, acc -> transform(acc, subject) end)
  end

  def run1 do
    loop_sizes = full_inputs |> find_loop_sizes([-1, -1], 1, 0)
    transform_with(full_inputs |> Enum.at(0), loop_sizes |> Enum.at(1))
  end

  def full_inputs do
    [9717666, 20089533]
  end
end
