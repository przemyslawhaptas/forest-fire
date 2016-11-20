defmodule ForestFire.CellularAutomaton do

  ########## Move to other modules

  def simulate do
    p_lightning_prob = 1
    f_growth_prob = 65
    params = { p_lightning_prob, f_growth_prob }

    do_simulate({ ForestFire.Utils.example_board(), params })
  end
  def do_simulate(state = { _, params }) do
    new_board = next_turn(state)
    ForestFire.ConsolePrinter.print(new_board)
    :timer.sleep(1000)
    do_simulate({ new_board, params })
  end

  ##########

  def next_turn({ { trees, burning_trees, empty_cells } = board,
                { p_lightning_prob, f_growth_prob } }) do

    burnt_trees = burn_trees_down(board)
    newly_ingnited_trees = spread_fire(board)
    struck_trees = strike_lightnings(board, p_lightning_prob)
    grown_trees = grow_trees(board, f_growth_prob)

    { trees
      |> MapSet.difference(newly_ingnited_trees)
      |> MapSet.difference(struck_trees)
      |> MapSet.union(grown_trees),

      burning_trees
      |> MapSet.difference(burnt_trees)
      |> MapSet.union(newly_ingnited_trees)
      |> MapSet.union(struck_trees),

      empty_cells
      |> MapSet.union(burnt_trees)
      |> MapSet.difference(grown_trees) }
  end

  def burn_trees_down({ _, burning_trees, _ }), do: burning_trees

  def spread_fire({ trees, burning_trees, _ }) do
    burning_trees
    |> adjacent_cells
    |> MapSet.intersection(trees)
  end

  def strike_lightnings({ trees, _, _ }, p_lightning_prob) do
    for tree <- trees, :rand.uniform(100) <= p_lightning_prob,
    do: tree,
    into: %MapSet{}
  end

  def grow_trees({ _, _, empty_cells }, f_growth_prob) do
    for empty_cell <- empty_cells, :rand.uniform(100) <= f_growth_prob,
    do: empty_cell,
    into: %MapSet{}
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
        !(x_cord == x && y_cord == y),
    do: { x_cord, y_cord },
    into: %MapSet{}
  end
end
