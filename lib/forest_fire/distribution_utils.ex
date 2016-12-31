defmodule ForestFire.DistributionUtils do
  @slave_nodes [:slave1@Przemek, :slave2@Przemek, :slave3@Przemek]

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
    available_slaves = MapSet.new(@slave_nodes)
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
