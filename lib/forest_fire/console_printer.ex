defmodule ForestFire.ConsolePrinter do
  def print(board, range_bounds) do
    board_map = transform_into_map(board)
    lines = build_lines(range_bounds, board_map)
    IO.puts(to_string(lines))
  end

  def transform_into_map({ trees, burning_trees, empty_cells }) do
    trees_marked = for tree <- trees,
      do: { tree, 'O' }, into: %{}
    burning_trees_marked = for burning_tree <- burning_trees,
      do: { burning_tree, 'x' }, into: %{}
    empty_cells_marked = for empty_cell <- empty_cells,
      do: { empty_cell, '_' }, into: %{}

    Enum.reduce([ trees_marked, burning_trees_marked, empty_cells_marked ],
      &(Map.merge(&1, &2)))
  end

  def build_lines({ x_range_bounds, { y_min, y_max } }, board_map) do
    Enum.map(y_max .. y_min, fn y ->
      build_line(y, x_range_bounds, board_map) end)
    ++ [ x_axis_legend(x_range_bounds)]
  end

  def build_line(y, { x_min, x_max }, board_map) do
    leading_string = number_legend_part(y) <> " "
    trailing_string = "\n"
    spacing = " "

    marks_list = Enum.map(x_min .. x_max, fn x ->
      get_cells_mark(board_map, { x, y }) end)
    spaced_marks_string = to_string_with_spacing(marks_list, spacing)

    leading_string <> spaced_marks_string <> trailing_string
  end

  def get_cells_mark(board_map, coords) do
    if mark = board_map[coords], do: mark, else: ' '
  end

  defp number_legend_part(num) when num < 0, do: "#{num}"
  defp number_legend_part(num), do: " #{num}"

  defp x_axis_legend({ x_min, x_max }) do
    spaced_x_axis =
      x_min .. x_max
      |> Enum.map(&number_legend_part/1)
      |> to_string

    "  " <> spaced_x_axis <> "\n"
  end

  # Check if having performance issues
  defp to_string_with_spacing(list, spacing) do
    list
    |> Enum.reduce("", fn (char, acc) ->
        to_string([ spacing, char | acc ]) end)
    |> String.reverse
    |> String.rstrip
  end
end
