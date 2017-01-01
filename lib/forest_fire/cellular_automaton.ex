defmodule ForestFire.CellularAutomaton do
  def next_turn({{trees, burning_trees, empty_cells} = board,
                {p_lightning_prob, f_growth_prob}}) do

    burnt_trees_ref = async(:burn_trees_down, [board])
    newly_ingnited_trees_ref = async(:spread_fire, [board])
    struck_trees_ref = async(:strike_lightnings, [board, p_lightning_prob])
    grown_trees_ref = async(:grow_trees, [board, f_growth_prob])

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

  def burn_trees_down({_, burning_trees, _}), do: burning_trees

  def spread_fire({trees, burning_trees, _}) do
    burning_trees
    |> Enum.map(fn burning_tree -> adjacent_cells(burning_tree) end)
    |> List.flatten
    |> MapSet.new
    |> MapSet.difference(burning_trees)
    |> MapSet.intersection(trees)
  end

  def strike_lightnings({trees, _, _}, p_lightning_prob) do
    for tree <- trees, :rand.uniform(10_000) <= p_lightning_prob * 100,
    do: tree,
    into: %MapSet{}
  end

  def grow_trees({_, _, empty_cells}, f_growth_prob) do
    for empty_cell <- empty_cells, :rand.uniform(10_000) <= f_growth_prob * 100,
    do: empty_cell,
    into: %MapSet{}
  end

  def adjacent_cells({x, y}) do
    for x_cord <- (x - 1)..(x + 1),
        y_cord <- (y - 1)..(y + 1),
        !(x_cord == x && y_cord == y),
    do: {x_cord, y_cord}
  end

  ## Helper functions

  defp async(fun_sym, args) do
    Task.Supervisor.async({ForestFire.TaskSupervisor, Node.self()},
      ForestFire.CellularAutomaton, fun_sym, args)
  end
  defp async(fun) do
    Task.Supervisor.async({ForestFire.TaskSupervisor, Node.self()}, fun)
  end
end
