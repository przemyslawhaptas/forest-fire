defmodule ForestFire.ConsolePrinter do
  def print(board, range_bounds) do
    board_map = transform_into_map(board)
    lines = build_lines(range_bounds, board_map)
    IO.puts(to_string(lines))
  end

  def transform_into_map({ trees, burning_trees, empty_cells }) do
    trees_marked = for tree <- trees,
      do: { tree, 'o' }, into: %{}
    burning_trees_marked = for burning_tree <- burning_trees,
      do: { burning_tree, '*' }, into: %{}
    empty_cells_marked = for empty_cell <- empty_cells,
      do: { empty_cell, '_' }, into: %{}

    [trees_marked, burning_trees_marked, empty_cells_marked]
    |> Enum.reduce(&(Map.merge(&1, &2)))
  end

  def build_lines({ x_range_bounds, { y_min, y_max } }, board_map) do
    y_max .. y_min
    |> Enum.map(fn y -> build_line(y, x_range_bounds, board_map) end)
    # <> column_number_legend(x_range_bounds)
  end

  def build_line(y, { x_min, x_max }, board_map) do
    line = (for x <- x_min .. x_max, do: get_cells_mark(board_map, { x, y }), into: [])
      |> Enum.reduce(" ", fn (char, line_acc) ->
          to_string([ " ", char | line_acc ]) end)
      |> String.reverse
      |> String.rstrip

    row_number_string(y) <> line <> "\n"
  end

  def get_cells_mark(board_map, coords) do
    if mark = board_map[coords], do: mark, else: ' '
  end

  defp padding_string(padding_size) do
    (for i <- 1 .. padding_size, do: " ")
    |> to_string
  end

  defp row_number_string(y) do
    if y < 0, do: "#{y}", else: " #{y}"
  end

  # defp column_number_legend({ x_min, x_max }) do
  #   "  "
  #   <> Enum.reduce(x_min .. x_max, " ", fn (column_number, line_acc) ->
  #             to_string([ " ", column_number | line_acc ]) end)
  #   <> "\n"
  # end
end
