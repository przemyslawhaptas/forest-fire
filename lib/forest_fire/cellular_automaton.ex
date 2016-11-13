defmodule ForestFire.CellularAutomaton do
  def burn_trees_down({ trees, burning_trees, empty_cells }) do
    { trees, %MapSet{},  MapSet.union(empty_cells, burning_trees) }
  end

  def spread_fire({ trees, burning_trees, empty_cells }) do
    newly_ingnited_trees =
      burning_trees
      |> adjacent_cells
      |> MapSet.intersection(trees)

    unaffected_trees = MapSet.difference(trees, newly_ingnited_trees)
    all_burning_trees = MapSet.union(burning_trees, newly_ingnited_trees)

    { unaffected_trees, all_burning_trees, empty_cells }
  end

  def strike_lightnings({ trees, burning_trees, e_c }, p_lightning_prob) do
    struck_trees =
      for tree <- trees, :rand.uniform(100) <= p_lightning_prob,
      into: %MapSet{},
      do: tree

    { MapSet.difference(trees, struck_trees),
      MapSet.union(burning_trees, struck_trees),
      e_c }
  end

  def grow_trees({ trees, b_t, empty_cells }, f_growth_prob) do
    grown_trees =
      for empty_cell <- empty_cells, :rand.uniform(100) <= f_growth_prob,
      into: %MapSet{},
      do: empty_cell

    { MapSet.union(trees, grown_trees),
      b_t,
      MapSet.difference(empty_cells, grown_trees) }
  end

  def adjacent_cells(%MapSet{} = cells) do
      cells
      |> Enum.reduce(%MapSet{}, fn(cell, adjacent_cells_acc) ->
          MapSet.union(adjacent_cells(cell), adjacent_cells_acc) end)
      |> MapSet.difference(cells)
  end
  def adjacent_cells({ x, y }) do
    for x_cord <- (x - 1)..(x + 1),
        y_cord <- (y - 1)..(y + 1),
        !(x_cord == x && y_cord == y), into: %MapSet{}, do: { x_cord, y_cord }
  end

  # def next_turn({ board, params }) do
  #   board1 = burn_trees_down(board)
  #   board2 = spread_fire(board)
  #   board3 = strike_a_lightning(board, p_lightning_prob)
  #   board4 = grow_trees(board, f_growth_prob)
  # end
end
