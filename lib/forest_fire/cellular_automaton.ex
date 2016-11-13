defmodule ForestFire.CellularAutomaton do
  def burn_trees_down({ trees, burning_trees, empty_cells }) do
    { trees, [],  (empty_cells ++ burning_trees) |> Enum.sort }
  end

  def spread_fire({ trees, burning_trees, empty_cells }) do
    newly_ingnited =
      burning_trees
      |> adjacent_cells
      |> affected_trees(trees)

    trees_after = (trees -- newly_ingnited) |> Enum.sort
    burning_trees_after = (burning_trees ++ newly_ingnited) |> Enum.sort

    { trees_after, burning_trees_after, empty_cells }
  end

  def adjacent_cells(cells) when cells |> is_list do
    all_adjacent_cells =
      cells
      |> Enum.reduce([], fn(cell, adjacent_cells_acc) ->
          adjacent_cells(cell) ++ adjacent_cells_acc end)
      |> Enum.uniq

    all_adjacent_cells -- cells
  end
  def adjacent_cells({ x, y }) do
    for x_cord <- (x - 1)..(x + 1),
        y_cord <- (y - 1)..(y + 1),
        !(x_cord == x && y_cord == y), do: { x_cord, y_cord }
  end

  def affected_trees(cells_in_fire_range, trees) do
    intersect_lists(cells_in_fire_range, trees)
  end

  def strike_lightnings({ trees, burning_trees, e_c }, p_lightning_prob) do
    struck_trees = for tree <- trees,
                       :rand.uniform(100) <= p_lightning_prob, do: tree

    { trees -- struck_trees, burning_trees ++ struck_trees, e_c }
  end

  def grow_trees({ trees, b_t, empty_cells }, f_growth_prob) do
    grown_trees = for empty_cell <- empty_cells,
                      :rand.uniform(100) <= f_growth_prob, do: empty_cell

    { trees ++ grown_trees, b_t, empty_cells -- grown_trees }
  end

  defp intersect_lists(list1, list2) do
    list1_uniq = Enum.uniq(list1)
    list2_uniq = Enum.uniq(list2)

    diff = list1_uniq -- list2_uniq
    list1_uniq -- diff
  end

  # def next_turn({ board, params }) do
  #   board1 = burn_trees_down(board)
  #   board2 = spread_fire(board)
  #   board3 = strike_a_lightning(board, p_lightning_prob)
  #   board4 = grow_trees(board, f_growth_prob)
  # end
  #
  # def strike_a_lightning(state) do
  #   state
  # end
  #
  # def grow_trees(state) do
  #   state
  # end
end
