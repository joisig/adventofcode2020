defmodule D20 do

  def flip(image) do
    Enum.reverse(image)
  end

  def rotate_left(image) do
    dim = Enum.at(image, 0) |> length
    Enum.map(1..dim, fn ix ->
      Enum.map(image, fn line ->
        Enum.at(Enum.reverse(line), ix - 1)
      end)
    end)
  end

  def top_edge(image), do: Enum.at(image, 0)

  def bottom_edge(image), do: Enum.at(image, -1)

  def left_edge(image) do
    Enum.map(image, fn line ->
      Enum.at(line, 0)
    end)
  end

  def right_edge(image) do
    Enum.map(image, fn line ->
      Enum.at(line, -1)
    end)
  end

  def borders(image) do
    [top_edge(image), right_edge(image), bottom_edge(image), left_edge(image)]
  end

  def possible_match(lb, rb) do
    Enum.reduce(lb, false, fn llb, acc ->
      Enum.reduce(rb, acc, fn rrb, acc ->
        case (llb == rrb) || (llb == Enum.reverse(rrb)) do
          true -> true
          false -> acc
        end
      end)
    end)
  end

  def all_possibilities(images, {cid, _, cborders}) do
    Enum.filter(images, fn {image_id, _, borders} ->
      case image_id == cid do
        true -> false
        _ ->
          possible_match(cborders, borders)
      end
    end)
  end

  def run1 do
    images = full_input_file |> read_file |> parse
    Enum.filter(images, fn image ->
      (all_possibilities(images, image) |> length) == 2
    end)
    |> Enum.reduce(1, fn {id, _, _}, acc -> acc * id end)
  end

  def neighbors(map, x, y) do
    [{x-1, y}, {x+1, y}, {x, y-1}, {x, y+1}] |> Enum.flat_map(fn {nx, ny} = coords ->
      case Map.get(map, coords) do
        nil ->
          []
        val ->
          [{{nx - x, ny - y}, val}]
      end
    end)
  end

  def satisfies_conditions(acc, x, y, choice) do
    choice_borders = choice |> elem 2
    neighbor_borders = neighbors(acc, x, y) |> Enum.map(fn val -> val |> elem(1) |> elem(2) end)

    non_matching = Enum.filter(neighbor_borders, fn nb ->
      !possible_match(choice_borders, nb)
    end)

    non_matching == []
  end

  def place(acc, x, y, choices) do
    # This would normally have to be a search algorithm, but we know from
    # processing the input data that based on edge matching, corners will
    # always have just two valid neighbors, edges always exactly 3, and insides
    # always exactly 4, so just iterating the matrix from left to right, top
    # to bottom, will generate a unique selection for each item except for
    # the first edge beside the first corner, which will have two choices, of
    # which we pick one (either choice would lead to the same solution only
    # transposed).
    [choice|rest] = Enum.filter(choices, fn c -> satisfies_conditions(acc, x, y, c) end)

    {Map.put(acc, {x, y}, choice), Enum.filter(choices, &(&1 != choice))}
  end

  def place_items(dim, corners, edges, inside) do
    Enum.reduce(0..(dim-1), {%{}, corners, edges, inside}, fn x, acc ->
      Enum.reduce(0..(dim-1), acc, fn y, {acc, c, e, i} ->
        case ((x == 0) || (x == (dim - 1))) && ((y == 0) || (y == (dim - 1))) do
          true ->
            {map, new_corners} = place(acc, x, y, c)
            {map, new_corners, e, i}
          false ->
            case (x == 0) || (x == (dim - 1)) || (y == 0) || (y == (dim - 1)) do
              true ->
                {map, new_edges} = place(acc, x, y, e)
                {map, c, new_edges, i}
              false ->
                {map, new_inside} = place(acc, x, y, i)
                {map, c, e, new_inside}
            end
        end
      end)
    end)
  end

  def all_perms(image) do
    image_270 = image |> rotate_left
    image_180 = image_270 |> rotate_left
    image_90 = image_180 |> rotate_left
    flimage = flip(image)
    flimage_270 = flimage |> rotate_left
    flimage_180 = flimage_270 |> rotate_left
    flimage_90 = flimage_180 |> rotate_left
    [image, image_270, image_180, image_90, flimage, flimage_270, flimage_180, flimage_90]
  end

  def valid_perm(perm, neighbors) do
    invalid_neighbors = Enum.filter(neighbors, fn {{xoff, yoff}, neighbor} ->
      # Indexes grow left to right, top to bottom
      is_valid = case {xoff, yoff} do
        {-1, 0} -> right_edge(neighbor) == left_edge(perm)
        {1, 0} -> left_edge(neighbor) == right_edge(perm)
        {0, -1} -> bottom_edge(neighbor) == top_edge(perm)
        {0, 1} -> top_edge(neighbor) == bottom_edge(perm)
      end
      !is_valid
    end)
    [] == invalid_neighbors
  end

  def rotate_items(arrangement, dim, acc, 0, dim) do
    acc
  end
  def rotate_items(arrangement, dim, acc, x, y) do
    {next_x, next_y} = case x == (dim - 1) do
      true ->
        {0, y + 1}
      _ ->
        {x + 1, y}
    end

    all_perms = all_perms(Map.get(arrangement, {x, y}) |> elem 1)

    neighbors = neighbors(acc, x, y)
    valid_perms = Enum.filter(all_perms, &(valid_perm(&1, neighbors)))
    case valid_perms do
      [] ->
        false
      _ ->
        Enum.find_value(valid_perms, fn perm ->
          nacc = Map.put(acc, {x, y}, perm)
          rotate_items(arrangement, dim, nacc, next_x, next_y)
        end)
    end
  end

  def run12 do
    images = full_input_file |> read_file |> parse
    dim = images |> length |> :math.sqrt |> round
    annotated = Enum.map(images, fn image ->
      {image, (all_possibilities(images, image) |> length)}
    end)
    corners = Enum.flat_map(annotated, fn {image, num} ->
      case num do
        2 -> [image]
        _ -> []
      end
    end)
    edges = Enum.flat_map(annotated, fn {image, num} ->
      case num do
        3 -> [image]
        _ -> []
      end
    end)
    inside = Enum.flat_map(annotated, fn {image, num} ->
      case num do
        4 -> [image]
        _ -> []
      end
    end)

    arrangement = place_items(dim, corners, edges, inside)
    arrangement |> elem(0) |> Map.values |> Enum.map(&(elem(&1, 0)))
    rotate_items(arrangement |> elem(0), dim, %{}, 0, 0)
  end

  def run2 do
    image = run12
    |> arrangement_to_img(12)

    [sea_monster_starts] = image
    |> all_perms
    |> Enum.map(fn perm ->
      find_sea_monsters(perm)
    end)
    |> Enum.filter(&(&1 != []))

    (List.flatten(image) |> Enum.count(&(&1 == "#"))) - (length(sea_monster_starts) * sea_monster_count)
  end

  def arrangement_to_img(arrangement, dim) do
    Enum.reduce(0..(dim-1), [], fn oy, yacc ->
      Enum.reduce(0..9, yacc, fn y, yacc ->
        line = Enum.reduce(0..(dim-1), [], fn ox, xacc ->
          Enum.reduce(0..9, xacc, fn x, xacc ->
            case x == 0 || x == 9 || y == 0 || y == 9 do
              true ->
                xacc
              false ->
                item = Map.get(arrangement, {ox, oy}) |> Enum.at(y) |> Enum.at(x)
                #IO.write(item)
                [item|xacc]
            end
          end)
        end)
        case line do
          [] ->
            yacc
          _ ->
            #IO.write("\n")
            [Enum.reverse(line)|yacc]
        end
      end)
    end)
    |> Enum.reverse
  end

  def visualize_arrangement(arrangement, dim) do
    Enum.map(0..(dim-1), fn oy ->
      Enum.map(0..9, fn y ->
        Enum.map(0..(dim-1), fn ox ->
          Enum.map(0..9, fn x ->
            IO.write(Map.get(arrangement, {ox, oy}) |> Enum.at(y) |> Enum.at(x))
          end)
          IO.write(" ")
        end)
        IO.write("\n")
      end)
      IO.write("\n")
    end)
  end

  def visualize_img(img) do
    Enum.map(img, fn line ->
      line |> Enum.join("") |> IO.write
      IO.write("\n")
    end)
  end

  def add_coords(set, line, y) do
    {set, _} = Enum.reduce(line, {set, 0}, fn g, {set, x} ->
      set = case g do
        "#" -> HashSet.put(set, {x, y})
        _ -> set
      end
      {set, x + 1}
    end)
    set
  end

  def sea_monster do
    [l1, l2, l3|_] = """
                  #
#    ##    ##    ###
 #  #  #  #  #  #
"""
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)

    coords = HashSet.new
    |> add_coords(l1, 0)
    |> add_coords(l2, 1)
    |> add_coords(l3, 2)
  end

  def sea_monster_count do
    sea_monster |> HashSet.size
  end

  def check_for_sea_monster(image, x, y) do
    offsets = sea_monster()
    Enum.count(offsets, fn {xoff, yoff} ->
      case Enum.at(image, y + yoff) do
        nil -> false
        list -> (list |> Enum.at(x + xoff)) == "#"
      end
    end)
    == sea_monster_count
  end

  def find_sea_monsters(image) do
    dim = Enum.at(image, 0) |> length
    Enum.flat_map(0..(dim - 1), fn y ->
      Enum.flat_map(0..(dim - 1), fn x ->
        case check_for_sea_monster(image, x, y) do
          true -> [{x, y}]
          false -> []
        end
      end)
    end)
  end

  def parse_chunk([name|lines]) do
    id = Regex.run(~r/Tile (\d+):/, name) |> Enum.at(1) |> String.to_integer
    lines = lines |> Enum.map(fn line -> String.graphemes(line) end)
    borders = borders(lines)
    {id, lines, borders}
  end

  def parse(lines) do
    Enum.reduce(lines ++ [""], {[], []}, fn line, {out, build} ->
      case line do
        "" ->
          {[Enum.reverse(build)|out], []}
        _ ->
          {out, [line|build]}
      end
    end)
    |> elem(0)
    |> Enum.map(&parse_chunk/1)
  end

  def read_file(filename) do
    File.stream!(filename) |> Enum.into([]) |> Enum.map(&(String.replace_trailing(&1, "\n", "")))
  end

  def test_file do
    "inputs/d20-test.txt"
  end

  def small_file do
    "inputs/d20-small.txt"
  end

  def full_input_file do
    "inputs/d20-full.txt"
  end

  def dummy_sea_monster_image do
    """
                  #
#    ##    ##    ###
 #  #  #  #  #  #
"""
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

end
