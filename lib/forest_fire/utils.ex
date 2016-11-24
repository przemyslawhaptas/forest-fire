defmodule ForestFire.Utils do
  def example_board({{x_min, x_max}, {y_min, y_max}} \\ {{-9, 9}, {-9, 9}}) do
    trees = for x <- x_min .. x_max, y <- y_min .. y_max,
      do: {x, y}, into: %MapSet{}

    { trees, %MapSet{}, %MapSet{} }
  end

  def board_holes(board, {{x_min, x_max}, {y_min, y_max}}) do
    all_cells = for x <- x_min .. x_max, y <- y_min .. y_max,
      do: { x, y }, into: %MapSet{}

    { trees, burning_trees, empty_cells } = board

    all_cells
    |> MapSet.difference(trees)
    |> MapSet.difference(burning_trees)
    |> MapSet.difference(empty_cells)
  end
end
