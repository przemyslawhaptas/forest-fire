defmodule ForestFire.DistributionUtils do
  def async(module \\ ForestFire.CellularAutomaton, fun_sym, args) do
    Task.Supervisor.async({ForestFire.TaskSupervisor, pick_node()},
      module, fun_sym, args)
  end
  def async(fun) do
    Task.Supervisor.async({ForestFire.TaskSupervisor, pick_node()}, fun)
  end

  def pick_node(strategy \\ &slaves_first/0) do
    strategy.()
  end

  def slaves_first do
    possible_slaves = Application.get_env(:forest_fire, :slave_nodes)
    available_slaves = MapSet.new(possible_slaves)
      |> MapSet.intersection(MapSet.new(all_nodes()))
      |> MapSet.to_list

    case available_slaves do
      [] -> Node.self
      _ -> Enum.random(available_slaves)
    end
  end

  defp all_nodes do
    [Node.self | Node.list]
  end
end
