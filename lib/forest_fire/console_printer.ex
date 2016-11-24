defmodule ForestFire.ConsolePrinter do
  # import ExProf.Macro

  def print(board, board_holes, board_bounds) do
    # profile do
      { { col_min, col_max }, _ } = board_bounds
      row_length = col_max - col_min + 1

      marked_board_cells = mark_board_cells(board)
      marked_board_holes_cells = mark_board_holes_cells(board_holes)

      build_printable_board(marked_board_cells, marked_board_holes_cells)
      |> chunk_rows(row_length)
      |> :io.format()
    # end
  end

  def mark_board_cells({ trees, burning_trees, empty_cells }) do
    marked_trees_set = for tree <- trees,
      do: { tree, "\e[42mO " }, into: %MapSet{}

    marked_trees_and_burning_trees_set = for burning_tree <- burning_trees,
      do: { burning_tree, "\e[41m* " }, into: marked_trees_set

    for empty_cell <- empty_cells,
      do: { empty_cell, "\e[47m  " }, into: marked_trees_and_burning_trees_set
  end

  def mark_board_holes_cells(board_holes) do
    for hole <- board_holes, do: { hole, "\e[0m  " }, into: %MapSet{}
  end

  def build_printable_board(marked_board_cells, marked_board_holes_cells) do
    marked_board_cells
    |> MapSet.union(marked_board_holes_cells)
    |> sort_marked_cells()
    |> Enum.map(fn { _, string } -> string end)
  end

  def chunk_rows(printable_board, row_length) do
    printable_board
    |> Enum.chunk(row_length)
    |> Enum.map(fn row -> [row, "\e[0m\n"] end)
  end

  def sort_marked_cells(marked_cells) do
    Enum.sort(marked_cells, fn ({ cords1, _ }, { cords2, _ }) ->
      compare_cords(cords1, cords2) end)
  end

  def compare_cords({ _col1, row1}, { _col2, row2 }) when row1 > row2, do: true
  def compare_cords({ col1, row1 }, { col2, row2 }) when row1 == row2 and col1 <= col2, do: true
  def compare_cords(_cords1, _cords2), do: false
end
