defmodule D17 do

  def run1 do
    i = full_input |> parse |> elem(0)
    visualize(i, -5..5, -5..5, 0)
    g = i |> next_gen
    visualize(g, -5..5, -5..5, -1)
    visualize(g, -5..5, -5..5, 0)
    visualize(g, -5..5, -5..5, 1)

    g
    |> next_gen
    |> next_gen
    |> next_gen
    |> next_gen
    |> next_gen
    |> MapSet.size
  end

  def run2 do
    i = full_input |> parse |> elem(0)
    i
    |> next_gen(4)
    |> next_gen(4)
    |> next_gen(4)
    |> next_gen(4)
    |> next_gen(4)
    |> next_gen(4)
    |> MapSet.size
  end

  def add_neighbor(map, coords) do
    case Map.get(map, coords) do
      nil -> Map.put(map, coords, 1)
      val -> Map.put(map, coords, val + 1)
    end
  end

  def neighbor_map(set, dimensions \\ 3) do
    w_range = case dimensions do
      3 -> 0..0
      4 -> -1..1
    end
    Enum.reduce(set, %{}, fn {x, y, z, w}, acc ->
      Enum.reduce(-1..1, acc, fn xoff, acc ->
        Enum.reduce(-1..1, acc, fn yoff, acc ->
          Enum.reduce(-1..1, acc, fn zoff, acc ->
            Enum.reduce(w_range, acc, fn woff, acc ->
              case {xoff, yoff, zoff, woff} do
                {0, 0, 0, 0} ->
                  acc
                _ ->
                  acc |> add_neighbor({x + xoff, y + yoff, z + zoff, w + woff})
              end
            end)
          end)
        end)
      end)
    end)
  end
  
  def next_gen(prev_gen, dimensions \\ 3) do
    Enum.reduce(neighbor_map(prev_gen, dimensions), MapSet.new, fn {coords, cn}, acc ->
      case MapSet.member?(prev_gen, coords) do
        true ->
          # Was active...
          case cn == 2 || cn == 3 do
            true -> MapSet.put(acc, coords)
            false -> acc
          end
        false ->
          # Was inactive...
          case cn == 3 do
            true -> MapSet.put(acc, coords)
            false -> acc
          end
      end
    end)
  end

  def parse(lines) do
    Enum.reduce(lines, {MapSet.new(), 0}, fn line, {set, line_num} ->
      cells = String.graphemes(line)
      {set, col_num} = Enum.reduce(cells, {set, 0}, fn cell, {set, col_num} ->
        case cell do
          "#" ->
            {MapSet.put(set, {line_num, col_num, 0, 0}), col_num + 1}
          _ ->
            {set, col_num + 1}
        end
      end)
      {set, line_num + 1}
    end)
  end

  def visualize(set, x_range, y_range, z) do
    IO.write("Visualizing z=#{z} plane\n\n")
    Enum.map(x_range, fn x ->
      Enum.map(y_range, fn y ->
        IO.write(case MapSet.member?(set, {x, y, z, 0}) do
          true -> "#"
          false -> "."
        end)
      end)
      IO.write("\n")
    end)
    IO.write("\n")
    :ok
  end
  
  def test_input do
    """
.#.
..#
###
"""
    |> String.split("\n") |> Enum.filter(&(&1 != ""))
  end

  def full_input do
    """
#.##.##.
.##..#..
....#..#
.##....#
#..##...
.###..#.
..#.#..#
.....#..
"""
    |> String.split("\n") |> Enum.filter(&(&1 != ""))
  end

end

