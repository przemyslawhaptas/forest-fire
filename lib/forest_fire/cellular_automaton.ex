defmodule ForestFire.CellularAutomaton do
  ########## Move to other modules

  def simulate do
    board_bounds = { {-60, 60}, {-40, 40} }
    board = ForestFire.Utils.example_board(board_bounds)
    board_holes = ForestFire.Utils.board_holes(board, board_bounds)

    p_lightning_prob = 0.05
    f_growth_prob = 4
    params = { p_lightning_prob, f_growth_prob }

    do_simulate({ board, board_holes, board_bounds, params })
  end
  def do_simulate({ board, board_holes, board_bounds, params }) do
    calculation_start_time = System.system_time()
    new_board = next_turn({ board, params })
    calculation_time = System.system_time() - calculation_start_time

    printing_start_time = System.system_time()
      ForestFire.ConsolePrinter.print(new_board, board_holes, board_bounds)
    printing_time = System.system_time() - printing_start_time

    IO.puts("calculation_time: #{calculation_time}")
    IO.puts("printing_time:    #{printing_time}")

    :timer.sleep(1000)

    do_simulate({ new_board, board_holes, board_bounds, params })
  end

  ##########

  def next_turn({ { trees, burning_trees, empty_cells } = board,
                { p_lightning_prob, f_growth_prob } }) do

    burnt_trees_ref = async(:burn_trees_down, [ board ])
    newly_ingnited_trees_ref = async(:spread_fire, [ board ])
    struck_trees_ref = async(:strike_lightnings, [ board, p_lightning_prob ])
    grown_trees_ref = async(:grow_trees, [ board, f_growth_prob ])

    burnt_trees = Task.await(burnt_trees_ref)
    newly_ingnited_trees = Task.await(newly_ingnited_trees_ref)
    struck_trees = Task.await(struck_trees_ref)
    grown_trees = Task.await(grown_trees_ref)

    new_trees_ref = async(fn () ->
      trees
      |> MapSet.difference(newly_ingnited_trees)
      |> MapSet.difference(struck_trees)
      |> MapSet.union(grown_trees) end)

    new_burning_trees_ref = async(fn () ->
      burning_trees
      |> MapSet.difference(burnt_trees)
      |> MapSet.union(newly_ingnited_trees)
      |> MapSet.union(struck_trees) end)

    new_empty_cells_ref = async(fn () ->
      empty_cells
      |> MapSet.union(burnt_trees)
      |> MapSet.difference(grown_trees) end)

    {
      Task.await(new_trees_ref),
      Task.await(new_burning_trees_ref),
      Task.await(new_empty_cells_ref)
    }
  end

  def burn_trees_down({ _, burning_trees, _ }), do: burning_trees

  def spread_fire({ trees, burning_trees, _ }) do
    burning_trees
    |> Enum.map(fn burning_tree -> async(:adjacent_cells, [ burning_tree ]) end)
    |> Enum.map(fn adjacent_cells_ref -> Task.await(adjacent_cells_ref) end)
    |> List.flatten
    |> MapSet.new
    |> MapSet.difference(burning_trees)
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

  def adjacent_cells({ x, y }) do
    for x_cord <- (x - 1)..(x + 1),
        y_cord <- (y - 1)..(y + 1),
        !(x_cord == x && y_cord == y),
    do: { x_cord, y_cord }
  end

  defp async(module \\ __MODULE__, fun_sym, args) do
    Task.Supervisor.async(
      { ForestFire.TaskSupervisor, ForestFire.NodeManager.pick_node() },
      module, fun_sym, args)
  end
  defp async(fun) do
    Task.Supervisor.async(
      { ForestFire.TaskSupervisor, ForestFire.NodeManager.pick_node() }, fun)
  end
end
