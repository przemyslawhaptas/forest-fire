defmodule ForestFire.CellularAutomaton do
  import ExProf.Macro

  ########## Move to other modules

  def simulate do
    p_lightning_prob = 0.05
    f_growth_prob = 4
    params = { p_lightning_prob, f_growth_prob }

    do_simulate({ ForestFire.Utils.example_board({ {-30, 30}, {-20, 20} }), params })
  end
  def do_simulate(state = { _, params }) do
    calculation_start_time = System.system_time()
    new_board = next_turn(state)
    calculation_time = System.system_time() - calculation_start_time
    IO.puts("calculation_time: #{calculation_time}")

    printing_start_time = System.system_time()
    # profile do
      ForestFire.ConsolePrinter.print(new_board, { {-30, 30}, {-20, 20} })
    # end
    printing_time = System.system_time() - printing_start_time
    IO.puts("printing_time: #{printing_time}")

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
    for tree <- trees, :rand.uniform(10000) <= p_lightning_prob * 100,
    do: tree,
    into: %MapSet{}
  end

  def grow_trees({ _, _, empty_cells }, f_growth_prob) do
    for empty_cell <- empty_cells, :rand.uniform(10000) <= f_growth_prob * 100,
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
