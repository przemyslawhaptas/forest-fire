defmodule ForestFire.DistributionUtils do
  def async(module \\ ForestFire.CellularAutomaton, fun_sym, args) do
    Task.Supervisor.async({ ForestFire.TaskSupervisor, pick_node() },
      module, fun_sym, args)
  end
  def async(fun) do
    Task.Supervisor.async({ ForestFire.TaskSupervisor, pick_node() }, fun)
  end

  def pick_node(strategy \\ &random_node/0) do
    strategy.()
  end

  def random_node do
    Enum.random(available_nodes())
  end

  defp available_nodes do
    [ Node.self | Node.list ]
  end
end
