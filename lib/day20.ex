defmodule D20 do

  def flip_lr(image) do
    Enum.map(image, &(Enum.reverse(&1)))
  end

  def flip_ud(image) do
    Enum.reverse(image)
  end

  def rotate_180(image) do
    image |> flip_lr |> flip_ud
  end

  def rotate_270(image) do
    dim = Enum.at(image, 0) |> length
    Enum.map(1..dim, fn ix ->
      Enum.map(image, fn line ->
        Enum.at(Enum.reverse(line), ix - 1)
      end)
    end)
  end

  def rotate_90(image) do
    image |> rotate_270 |> rotate_180
  end

  def rotate_0(image) do
    image
  end

  def gen_candidates(image) do
    Enum.reduce([&flip_ud/1, &flip_lr/1], [], fn flip_func, acc ->
      Enum.reduce([&rotate_0/1, &rotate_90/1, &rotate_180/1, &rotate_270/1], acc, fn rot_func, acc ->
        [rot_func.(flip_func.(image))|acc]
      end)
    end)
    |> Enum.uniq
  end

  def borders(image) do
    left = Enum.map(image, fn line ->
      Enum.at(line, 0)
    end)
    right = Enum.map(image, fn line ->
      Enum.at(line, -1)
    end)
    [Enum.at(image, 0), right, Enum.at(image, -1), left]
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

  def full_input_file do
    "inputs/d20-full.txt"
  end
end
